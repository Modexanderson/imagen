import 'package:flutter/cupertino.dart';

import 'messaged_firebase_auth_exception.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class FirebaseSignInAuthException extends MessagedFirebaseAuthException {
  FirebaseSignInAuthException(
      {String message = "Instance of FirebaseSignInAuthException"})
      : super(message);
}

class FirebaseSignInAuthUserDisabledException
    extends FirebaseSignInAuthException {
  FirebaseSignInAuthUserDisabledException( BuildContext context,
      {String message = ""})
      : super(message: message.isNotEmpty ? message : AppLocalizations.of(context)!.userDisabledException);
}

class FirebaseSignInAuthUserNotFoundException
    extends FirebaseSignInAuthException {
  FirebaseSignInAuthUserNotFoundException( BuildContext context,
      {String message = ""})
      : super(message: message.isNotEmpty ? message : AppLocalizations.of(context)!.userNotFoundException);
}

class FirebaseSignInAuthInvalidEmailException
    extends FirebaseSignInAuthException {
  FirebaseSignInAuthInvalidEmailException( BuildContext context,
      {String message = ""})
      : super(message: message.isNotEmpty ? message : AppLocalizations.of(context)!.invalidEmailException);
}

class FirebaseSignInAuthWrongPasswordException
    extends FirebaseSignInAuthException {
  FirebaseSignInAuthWrongPasswordException(BuildContext context, {String message = ""})
      : super(message: message.isNotEmpty ? message : AppLocalizations.of(context)!.wrongPasswordException);
}

class FirebaseTooManyRequestsException extends FirebaseSignInAuthException {
  FirebaseTooManyRequestsException( BuildContext context,
      {String message = ""})
      : super(message: message.isNotEmpty ? message : AppLocalizations.of(context)!.signInFailed);
}

class FirebaseSignInAuthUserNotVerifiedException
    extends FirebaseSignInAuthException {
  FirebaseSignInAuthUserNotVerifiedException( BuildContext context,
      {String message = ""})
      : super(message: message.isNotEmpty ? message : AppLocalizations.of(context)!.emailVerificationMessage);
}

class FirebaseSignInAuthUnknownReasonFailure
    extends FirebaseSignInAuthException {
  FirebaseSignInAuthUnknownReasonFailure( BuildContext context,
      {String message = ""})
      : super(message: message.isNotEmpty ? message : AppLocalizations.of(context)!.signInFailed);
}
