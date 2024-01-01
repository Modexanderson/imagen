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
import '../widgets/snack_bar.dart';
import 'database/user_database_helper.dart';

class AuthentificationService {

  String getLocalizedErrorMessage(String errorCode, BuildContext context) {
    switch (errorCode) {
      case 'user-not-found':
        return AppLocalizations.of(context)!.userNotFoundException;
      case 'wrong-password':
        return AppLocalizations.of(context)!.wrongPasswordException;
      case 'too-many-requests':
        return AppLocalizations.of(context)!.tooManyRequestException;
      case 'email-already-in-use':
            return AppLocalizations.of(context)!.emailAlreadyInUseException;
      case 'operation-not-allowed':
        return AppLocalizations.of(context)!.operationNotAllowException;
      case 'weak-password':
        return AppLocalizations.of(context)!.weakPasswordException;
      case 'user-mismatch':
        return AppLocalizations.of(context)!.userMismatchException;
      case 'invalid-credential':
        return AppLocalizations.of(context)!.invalidCredentialException;
      case 'invalid-email':
        return AppLocalizations.of(context)!.invalidEmailException;
      case 'invalid-verification-code':
        return AppLocalizations.of(context)!.invalidVerificationCodeException;
      case 'user-disabled':
        return AppLocalizations.of(context)!.userDisabledException;
      case 'invalid-verification-id':
        return AppLocalizations.of(context)!.invalidVerificationIdException;
      case 'requires-recent-login':
        return AppLocalizations.of(context)!.requiredRecentLoginException;
     
      // Add more cases as needed for specific error messages
      default:
        return AppLocalizations.of(context)!.error;
    }
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

  Future<bool> reauthCurrentUser(BuildContext context, password) async {
    try {
      UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
              email: currentUser.email!, password: password);
      userCredential = await currentUser
          .reauthenticateWithCredential(userCredential.credential!);
    } on FirebaseAuthException catch (e) {
      String errorMessage = getLocalizedErrorMessage(e.code, context);
      ShowSnackBar().showSnackBar(context, errorMessage);
    } catch (e) {
      throw FirebaseReauthUnknownReasonFailureException(message: e.toString());
    }
    return true;
  }

  Future<bool> signIn(BuildContext context, {String? email, String? password}) async {
    try {
      final UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
              email: email.toString(), password: password.toString());
      if (userCredential.user!.emailVerified) {
        return true;
      } else {
        await userCredential.user!.sendEmailVerification();
        throw FirebaseSignInAuthUserNotVerifiedException(context);
      }
    } on MessagedFirebaseAuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      String errorMessage = getLocalizedErrorMessage(e.code, context);
      ShowSnackBar().showSnackBar(context, errorMessage);
      return false;
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
    await UserDatabaseHelper().createNewUser(uid, email!);
    return true;
  }on FirebaseAuthException catch (e) {
     String errorMessage = getLocalizedErrorMessage(e.code, context);
      ShowSnackBar().showSnackBar(context, errorMessage);
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

  Future<bool> signUpWithGoogle( BuildContext context) async {
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
    final String email = googleSignInAccount.email;

    // Check if the user already exists in the database
    if (!(await UserDatabaseHelper().userExists(uid))) {
      // User doesn't exist, create a new user
      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      await UserDatabaseHelper().createNewUser(uid, email);
    }

    return true;
  } on FirebaseAuthException catch (e) {
    String errorMessage = getLocalizedErrorMessage(e.code, context);
      ShowSnackBar().showSnackBar(context, errorMessage);
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

  Future<bool> signUpWithApple(BuildContext context) async {
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
      final String email = appleCredential.email ?? '';

      if (!userCredential.user!.emailVerified) {
        await userCredential.user!.sendEmailVerification();
      }

      // Check if the user already exists in the database
      if (!(await UserDatabaseHelper().userExists(uid))) {
        // User doesn't exist, create a new user
        await UserDatabaseHelper().createNewUser(uid, email);
      }

      return true;
    } on FirebaseAuthException catch (e) {
      String errorMessage = getLocalizedErrorMessage(e.code, context);
      ShowSnackBar().showSnackBar(context, errorMessage);
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

  Future<bool> resetPasswordForEmail(BuildContext context, String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } on MessagedFirebaseAuthException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      String errorMessage = getLocalizedErrorMessage(e.code, context);
      ShowSnackBar().showSnackBar(context, errorMessage);
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changePasswordForCurrentUser( BuildContext context,
      {String? oldPassword, required String? newPassword}) async {
    try {
      bool isOldPasswordProvidedCorrect = true;
      if (oldPassword != null) {
        isOldPasswordProvidedCorrect =
            await verifyCurrentUserPassword(context, oldPassword);
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
      String errorMessage = getLocalizedErrorMessage(e.code, context);
      ShowSnackBar().showSnackBar(context, errorMessage);
      return false;

    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changeEmailForCurrentUser( BuildContext context,
      {String? password, String? newEmail}) async {
    try {
      bool isPasswordProvidedCorrect = true;
      if (password != null) {
        isPasswordProvidedCorrect = await verifyCurrentUserPassword(context, password);
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

  Future<bool> verifyCurrentUserPassword(BuildContext context, String password) async {
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
      String errorMessage = getLocalizedErrorMessage(e.code, context);
      ShowSnackBar().showSnackBar(context, errorMessage);
      return false;
    } catch (e) {
      rethrow;
    }
  }
}
