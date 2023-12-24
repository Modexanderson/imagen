import 'package:flutter/material.dart';

import 'messaged_firebase_auth_exception.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class FirebaseSignUpAuthException extends MessagedFirebaseAuthException {
  FirebaseSignUpAuthException(
      {String message = "Instance of FirebaseSignUpAuthException"})
      : super(message);
}

class FirebaseSignUpAuthEmailAlreadyInUseException
    extends FirebaseSignUpAuthException {
  FirebaseSignUpAuthEmailAlreadyInUseException( BuildContext context,
      {String message = ""})
      : super(message: message.isNotEmpty ? message : AppLocalizations.of(context)!.emailAlreadyInUseException);
}


class FirebaseSignUpAuthInvalidEmailException
    extends FirebaseSignUpAuthException {
  FirebaseSignUpAuthInvalidEmailException( BuildContext context,
      {String message = ""})
      : super(message: message.isNotEmpty ? message : AppLocalizations.of(context)!.invalidEmailException);
}

class FirebaseSignUpAuthOperationNotAllowedException
    extends FirebaseSignUpAuthException {
  FirebaseSignUpAuthOperationNotAllowedException( BuildContext context,
      {String message = ""})
      : super(message: message.isNotEmpty ? message : AppLocalizations.of(context)!.signInFailed);
}

class FirebaseSignUpAuthWeakPasswordException
    extends FirebaseSignUpAuthException {
  FirebaseSignUpAuthWeakPasswordException( BuildContext context,
      {String message = ""})
      : super(message: message.isNotEmpty ? message : AppLocalizations.of(context)!.weakPasswordException);
}

class FirebaseSignUpAuthUnknownReasonFailureException
    extends FirebaseSignUpAuthException {
  FirebaseSignUpAuthUnknownReasonFailureException( BuildContext context,
      {String message = ""})
      : super(message: message.isNotEmpty ? message : AppLocalizations.of(context)!.signInFailed);
}
