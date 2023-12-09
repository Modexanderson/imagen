import 'package:firebase_auth/firebase_auth.dart';

abstract class MessagedFirebaseAuthException extends FirebaseAuthException {
  final _message;
  MessagedFirebaseAuthException(this._message) : super(code: _message);
  String get message => _message;
  @override
  String toString() {
    return message;
  }
}
