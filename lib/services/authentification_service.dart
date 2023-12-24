import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../exceptions/credential_actions_exception.dart';
import '../exceptions/firebase_sign_in_exceptions.dart';
import '../exceptions/firebase_sign_up_exception.dart';
import '../exceptions/messaged_firebase_auth_exception.dart';
import '../exceptions/reauth_exceptions.dart';
import 'database/user_database_helper.dart';

class AuthentificationService {
  // static const String USER_NOT_FOUND_EXCEPTION_CODE = "user-not-found";
  static String GET_USER_NOT_FOUND_EXCEPTION_CODE(BuildContext context) {
    return AppLocalizations.of(context)!.userNotFoundException;
  }
  // static const String WRONG_PASSWORD_EXCEPTION_CODE = "wrong-password";
  static String GET_WRONG_PASSWORD_EXCEPTION_CODE(BuildContext context) {
    return AppLocalizations.of(context)!.wrongPasswordException;
  }
  // static const String TOO_MANY_REQUESTS_EXCEPTION_CODE = 'too-many-requests';
  static String GET_TOO_MANY_REQUESTS_EXCEPTION_CODE(BuildContext context) {
    return AppLocalizations.of(context)!.tooManyRequestException;
  }
  // static const String EMAIL_ALREADY_IN_USE_EXCEPTION_CODE =
  //     "email-already-in-use";
  static String GET_EMAIL_ALREADY_IN_USE_EXCEPTION_CODE(BuildContext context) {
    return AppLocalizations.of(context)!.emailAlreadyInUseException;
  }
  // static const String OPERATION_NOT_ALLOWED_EXCEPTION_CODE =
  //     "operation-not-allowed";
  static String GET_OPERATION_NOT_ALLOWED_EXCEPTION_CODE(BuildContext context) {
    return AppLocalizations.of(context)!.operationNotAllowException;
  }
  // static const String WEAK_PASSWORD_EXCEPTION_CODE = "weak-password";
  static String GET_WEAK_PASSWORD_EXCEPTION_CODE(BuildContext context) {
    return AppLocalizations.of(context)!.weakPasswordException;
  }
  // static const String USER_MISMATCH_EXCEPTION_CODE = "user-mismatch";
  static String GET_USER_MISMATCH_EXCEPTION_CODE(BuildContext context) {
    return AppLocalizations.of(context)!.userMismatchException;
  }
  // static const String INVALID_CREDENTIALS_EXCEPTION_CODE = "invalid-credential";
  static String GET_INVALID_CREDENTIAL_EXCEPTION_CODE(BuildContext context) {
    return AppLocalizations.of(context)!.invalidCredentialException;
  }
  // static const String INVALID_EMAIL_EXCEPTION_CODE = "invalid-email";
  static String GET_INVALID_EMAIL_EXCEPTION_CODE(BuildContext context) {
    return AppLocalizations.of(context)!.invalidEmailException;
  }
  // static const String USER_DISABLED_EXCEPTION_CODE = "user-disabled";
  static String GET_USER_DISABLED_EXCEPTION_CODE(BuildContext context) {
    return AppLocalizations.of(context)!.userDisabledException;
  }
  // static const String INVALID_VERIFICATION_CODE_EXCEPTION_CODE =
  //     "invalid-verification-code";
  static String GET_INVALID_VERIFICATION_CODE_EXCEPTION_CODE(BuildContext context) {
    return AppLocalizations.of(context)!.invalidVerificationCodeException;
  }
  // static const String INVALID_VERIFICATION_ID_EXCEPTION_CODE =
  //     "invalid-verification-id";
  static String GET_INVALID_VERIFICATION_ID_EXCEPTION_CODE(BuildContext context) {
    return AppLocalizations.of(context)!.invalidVerificationIdException;
  }
  // static const String REQUIRES_RECENT_LOGIN_EXCEPTION_CODE =
  //     "requires-recent-login";
  static String GET_REQUIRES_RECENT_LOGIN_EXCEPTION_CODE(BuildContext context) {
    return AppLocalizations.of(context)!.requiredRecentLoginException;
  }

  FirebaseAuth? _firebaseAuth;

  AuthentificationService._privateConstructor();
  static final AuthentificationService _instance =
      AuthentificationService._privateConstructor();

  FirebaseAuth get firebaseAuth {
    _firebaseAuth ??= FirebaseAuth.instance;
    return _firebaseAuth!;
  }

  factory AuthentificationService() {
    return _instance;
  }

  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  Stream<User?> get userChanges => firebaseAuth.userChanges();

  Future<void> deleteUserAccount() async {
    await currentUser.delete();
    await signOut();
  }

  Future<bool> reauthCurrentUser(password) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
              email: currentUser.email!, password: password);
      userCredential = await currentUser
          .reauthenticateWithCredential(userCredential.credential!);
    } on FirebaseAuthException catch (e) {
      if (e.code == GET_WRONG_PASSWORD_EXCEPTION_CODE) {
        throw FirebaseSignInAuthWrongPasswordException();
      } else {
        throw FirebaseSignInAuthException(message: e.code);
      }
    } catch (e) {
      throw FirebaseReauthUnknownReasonFailureException(message: e.toString());
    }
    return true;
  }

  Future<bool> signIn({String? email, String? password}) async {
    try {
      final UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
              email: email.toString(), password: password.toString());
      if (userCredential.user!.emailVerified) {
        return true;
      } else {
        await userCredential.user!.sendEmailVerification();
        throw FirebaseSignInAuthUserNotVerifiedException();
      }
    } on MessagedFirebaseAuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case GET_INVALID_EMAIL_EXCEPTION_CODE:
          throw FirebaseSignInAuthInvalidEmailException();

        case GET_USER_DISABLED_EXCEPTION_CODE:
          throw FirebaseSignInAuthUserDisabledException();

        case GET_USER_NOT_FOUND_EXCEPTION_CODE:
          throw FirebaseSignInAuthUserNotFoundException();

        case GET_WRONG_PASSWORD_EXCEPTION_CODE:
          throw FirebaseSignInAuthWrongPasswordException();

        case GET_TOO_MANY_REQUESTS_EXCEPTION_CODE:
          throw FirebaseTooManyRequestsException();

        default:
          throw FirebaseSignInAuthException(message: e.code);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Future<bool> signUp({String? email, String? password}) async {
  //   try {
  //     final UserCredential userCredential =
  //         await firebaseAuth.createUserWithEmailAndPassword(
  //             email: email.toString(), password: password.toString());
  //     final String uid = userCredential.user!.uid;
  //     if (userCredential.user!.emailVerified == false) {
  //       await userCredential.user!.sendEmailVerification();
  //     }
  //     await UserDatabaseHelper().createNewUser(uid);
  //     return true;
  //   } on MessagedFirebaseAuthException {
  //     rethrow;
  //   } on FirebaseAuthException catch (e) {
  //     switch (e.code) {
  //       case GET_EMAIL_ALREADY_IN_USE_EXCEPTION_CODE:
  //         throw FirebaseSignUpAuthEmailAlreadyInUseException();
  //       case GET_INVALID_EMAIL_EXCEPTION_CODE:
  //         throw FirebaseSignUpAuthInvalidEmailException();
  //       case GET_OPERATION_NOT_ALLOWED_EXCEPTION_CODE:
  //         throw FirebaseSignUpAuthOperationNotAllowedException();
  //       case GET_WEAK_PASSWORD_EXCEPTION_CODE:
  //         throw FirebaseSignUpAuthWeakPasswordException();
  //       default:
  //         throw FirebaseSignInAuthException(message: e.code);
  //     }
  //   } catch (e) {
  //     rethrow;
  //   }
  // }


Future<bool> signUp(BuildContext context, {String? email, String? password}) async {
  try {
    final UserCredential userCredential =
        await firebaseAuth.createUserWithEmailAndPassword(
            email: email.toString(), password: password.toString());
    final String uid = userCredential.user!.uid;
    if (userCredential.user!.emailVerified == false) {
      await userCredential.user!.sendEmailVerification();
    }
    await UserDatabaseHelper().createNewUser(uid);
    return true;
  } on MessagedFirebaseAuthException {
    rethrow;
  } on FirebaseAuthException catch (e) {
    switch (e.code) {
      case GET_EMAIL_ALREADY_IN_USE_EXCEPTION_CODE:
        throw FirebaseSignUpAuthEmailAlreadyInUseException(context);
      case GET_INVALID_EMAIL_EXCEPTION_CODE:
        throw FirebaseSignUpAuthInvalidEmailException(context);
      case GET_OPERATION_NOT_ALLOWED_EXCEPTION_CODE:
        throw FirebaseSignUpAuthOperationNotAllowedException(context);
      case GET_WEAK_PASSWORD_EXCEPTION_CODE:
        throw FirebaseSignUpAuthWeakPasswordException(context);
    }
    // Return false if the switch block doesn't match any case
    return false;
  } catch (e) {
    rethrow;
  }
}





  // Future<bool> signUpWithGoogle() async {
  //   try {
  //     final GoogleSignInAccount? googleSignInAccount =
  //         await GoogleSignIn().signIn();
  //     if (googleSignInAccount == null) {
  //       // The user canceled the sign-in process
  //       return false;
  //     }

  //     final GoogleSignInAuthentication googleSignInAuthentication =
  //         await googleSignInAccount.authentication;
  //     final AuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleSignInAuthentication.accessToken,
  //       idToken: googleSignInAuthentication.idToken,
  //     );

  //     final UserCredential userCredential =
  //         await _firebaseAuth!.signInWithCredential(credential);

  //     final String uid = userCredential.user!.uid;

  //     if (!userCredential.user!.emailVerified) {
  //       await userCredential.user!.sendEmailVerification();
  //     }

  //     await UserDatabaseHelper().createNewUser(uid);

  //     return true;
  //   } on FirebaseAuthException catch (e) {
  //     // Handle FirebaseAuthException
  //     print(e.message);
  //     return false;
  //   } catch (e) {
  //     // Handle other exceptions
  //     print(e.toString());
  //     return false;
  //   }
  // }

  Future<bool> signUpWithGoogle() async {
  try {
    final GoogleSignInAccount? googleSignInAccount =
        await GoogleSignIn().signIn();
    
    if (googleSignInAccount == null) {
      // The user canceled the sign-in process
      return false;
    }

    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential userCredential =
        await _firebaseAuth!.signInWithCredential(credential);

    final String uid = userCredential.user!.uid;

    // Check if the user already exists in the database
    if (!(await UserDatabaseHelper().userExists(uid))) {
      // User doesn't exist, create a new user
      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      await UserDatabaseHelper().createNewUser(uid);
    }

    return true;
  } on FirebaseAuthException catch (e) {
    // Handle FirebaseAuthException
    print(e.message);
    return false;
  } catch (e) {
    // Handle other exceptions
    print(e.toString());
    return false;
  }
}


  // Future<bool> signUpWithApple() async {
  //   try {
  //     final AuthorizationCredentialAppleID appleCredential =
  //         await SignInWithApple.getAppleIDCredential(scopes: [
  //       AppleIDAuthorizationScopes.email,
  //       AppleIDAuthorizationScopes.fullName,
  //     ]);

  //     final String nonce = generateNonce(); // Generate a nonce
  //     final AuthCredential credential = OAuthProvider('apple.com').credential(
  //       idToken: appleCredential.identityToken,
  //       rawNonce: nonce,
  //     );

  //     final UserCredential userCredential =
  //         await _firebaseAuth!.signInWithCredential(credential);

  //     final String uid = userCredential.user!.uid;

  //     if (!userCredential.user!.emailVerified) {
  //       await userCredential.user!.sendEmailVerification();
  //     }

  //     await UserDatabaseHelper().createNewUser(uid);

  //     return true;
  //   } on FirebaseAuthException catch (e) {
  //     // Handle FirebaseAuthException
  //     print(e.message);
  //     return false;
  //   } catch (e) {
  //     // Handle other exceptions
  //     print(e.toString());
  //     return false;
  //   }
  // }

  Future<bool> signUpWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]);

      final String nonce = generateNonce(); // Generate a nonce
      final AuthCredential credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: nonce,
      );

      final UserCredential userCredential =
          await _firebaseAuth!.signInWithCredential(credential);

      final String uid = userCredential.user!.uid;

      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      // Check if the user already exists in the database
      if (!(await UserDatabaseHelper().userExists(uid))) {
        // User doesn't exist, create a new user
        await UserDatabaseHelper().createNewUser(uid);
      }

      return true;
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException
      print(e.message);
      return false;
    } catch (e) {
      // Handle other exceptions
      print(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  bool get currentUserVerified {
    currentUser.reload();
    return currentUser.emailVerified;
  }

  Future<bool> sendVerificationEmailToCurrentUser() async {
    try {
      await firebaseAuth.currentUser!.sendEmailVerification();
      return true; // Email verification succeeded
    } catch (error) {
      print("Error during email verification: $error");
      return false; // Email verification failed
    }
  }

  User get currentUser {
    return firebaseAuth.currentUser!;
  }

  Future<void> updateCurrentUserDisplayName(String updatedDisplayName) async {
    await currentUser.updateProfile(displayName: updatedDisplayName);
  }

  Future<bool> resetPasswordForEmail(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } on MessagedFirebaseAuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      if (e.code == GET_USER_NOT_FOUND_EXCEPTION_CODE) {
        throw FirebaseCredentialActionAuthUserNotFoundException();
      } else {
        throw FirebaseCredentialActionAuthException(message: e.code);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changePasswordForCurrentUser(
      {String? oldPassword, required String? newPassword}) async {
    try {
      bool isOldPasswordProvidedCorrect = true;
      if (oldPassword != null) {
        isOldPasswordProvidedCorrect =
            await verifyCurrentUserPassword(oldPassword);
      }
      if (isOldPasswordProvidedCorrect) {
        await firebaseAuth.currentUser!.updatePassword(newPassword.toString());

        return true;
      } else {
        throw FirebaseReauthWrongPasswordException();
      }
    } on MessagedFirebaseAuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case GET_WEAK_PASSWORD_EXCEPTION_CODE:
          throw FirebaseCredentialActionAuthWeakPasswordException();
        case GET_REQUIRES_RECENT_LOGIN_EXCEPTION_CODE:
          throw FirebaseCredentialActionAuthRequiresRecentLoginException();
        default:
          throw FirebaseCredentialActionAuthException(message: e.code);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changeEmailForCurrentUser(
      {String? password, String? newEmail}) async {
    try {
      bool isPasswordProvidedCorrect = true;
      if (password != null) {
        isPasswordProvidedCorrect = await verifyCurrentUserPassword(password);
      }
      if (isPasswordProvidedCorrect) {
        await currentUser.verifyBeforeUpdateEmail(newEmail.toString());

        return true;
      } else {
        throw FirebaseReauthWrongPasswordException();
      }
    } on MessagedFirebaseAuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw FirebaseCredentialActionAuthException(message: e.code);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyCurrentUserPassword(String password) async {
    try {
      final AuthCredential authCredential = EmailAuthProvider.credential(
        email: currentUser.email.toString(),
        password: password,
      );

      final authCredentials = await currentUser
          .reauthenticateWithCredential(authCredential) as AuthCredential?;
      return authCredentials != null;
    } on MessagedFirebaseAuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case GET_USER_MISMATCH_EXCEPTION_CODE:
          throw FirebaseReauthUserMismatchException();
        case GET_USER_NOT_FOUND_EXCEPTION_CODE:
          throw FirebaseReauthUserNotFoundException();
        case GET_INVALID_CREDENTIAL_EXCEPTION_CODE:
          throw FirebaseReauthInvalidCredentialException();
        case GET_INVALID_EMAIL_EXCEPTION_CODE:
          throw FirebaseReauthInvalidEmailException();
        case GET_WRONG_PASSWORD_EXCEPTION_CODE:
          throw FirebaseReauthWrongPasswordException();
        case GET_INVALID_VERIFICATION_CODE_EXCEPTION_CODE:
          throw FirebaseReauthInvalidVerificationCodeException();
        case GET_INVALID_VERIFICATION_ID_EXCEPTION_CODE:
          throw FirebaseReauthInvalidVerificationIdException();
        default:
          throw FirebaseReauthException(message: e.code);
      }
    } catch (e) {
      rethrow;
    }
  }
}
