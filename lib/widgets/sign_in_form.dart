import 'package:flutter/material.dart';
import 'package:imagen/widgets/snack_bar.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../exceptions/firebase_sign_in_exceptions.dart';
import '../exceptions/messaged_firebase_auth_exception.dart';
import '../models/constants.dart';
import '../models/size_config.dart';
import '../screens/forgot_password_screen.dart';
import '../services/authentification_service.dart';
import 'async_progress_dialog.dart';
import 'default_button.dart';

class SignInForm extends StatefulWidget {
  @override
  _SignInFormState createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formkey = GlobalKey<FormState>();
  bool isPasswordVisible = false;

  final TextEditingController emailFieldController = TextEditingController();
  final TextEditingController passwordFieldController = TextEditingController();

  @override
  void dispose() {
    emailFieldController.dispose();
    passwordFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Column(
        children: [
          buildEmailFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildPasswordFormField(),
          SizedBox(height: getProportionateScreenHeight(30)),
          buildForgotPasswordWidget(context),
          SizedBox(height: getProportionateScreenHeight(30)),
          DefaultButton(
            text: AppLocalizations.of(context)!.signIn,
            press: signInButtonCallback,
          ),
        ],
      ),
    );
  }

  Row buildForgotPasswordWidget(BuildContext context) {
    return Row(
      children: [
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                ));
          },
          child: Text(
            AppLocalizations.of(context)!.forgotPassword,
            style: const TextStyle(
              decoration: TextDecoration.underline,
            ),
          ),
        )
      ],
    );
  }

  Widget buildPasswordFormField() {
    return TextFormField(
      controller: passwordFieldController,
      obscureText: !isPasswordVisible,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.enterPassword,
        labelText: AppLocalizations.of(context)!.password,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: GestureDetector(
          onTap: () {
            // Toggle the visibility of the password
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
          child: Icon(
            isPasswordVisible ? Icons.visibility : Icons.visibility_off,
          ),
        ),
      ),
      validator: (value) {
        if (passwordFieldController.text.isEmpty) {
          return AppStrings.getPassNullError(context);
        } else if (passwordFieldController.text.length < 8) {
          return AppStrings.getShortPassError(context);
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildEmailFormField() {
    return TextFormField(
      controller: emailFieldController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.enterEmail,
        labelText: AppLocalizations.of(context)!.email,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: const Icon(
          Icons.mail,
        ),
      ),
      validator: (value) {
        if (emailFieldController.text.isEmpty) {
          return AppStrings.getEmailNullError(context);
        } else if (!emailValidatorRegExp.hasMatch(emailFieldController.text)) {
          return AppStrings.getInvalidEmailError(context);
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Future<void> signInButtonCallback() async {
    if (_formkey.currentState!.validate()) {
      _formkey.currentState!.save();
      final AuthentificationService authService = AuthentificationService();
      bool signInStatus = false;
      String? snackbarMessage;
      try {
        final signInFuture = authService.signIn(
          email: emailFieldController.text.trim(),
          password: passwordFieldController.text.trim(),
        );
        //signInFuture.then((value) => signInStatus = value);
        signInStatus = await showDialog(
          context: context,
          builder: (context) {
            return AsyncProgressDialog(
              signInFuture,
              message: Text(AppLocalizations.of(context)!.signInProcess),
              onError: (e) {
                snackbarMessage = e.toString();
              },
            );
          },
        );
        if (signInStatus == true) {
          snackbarMessage = AppLocalizations.of(context)!.signInSuccessful;
        } else {
          if (snackbarMessage == null) {
            throw FirebaseSignInAuthUnknownReasonFailure();
          } else {
            throw FirebaseSignInAuthUnknownReasonFailure(
                message: snackbarMessage!);
          }
        }
      } on MessagedFirebaseAuthException catch (e) {
        snackbarMessage = e.message;
      } catch (e) {
        snackbarMessage = e.toString();
      } finally {
        Logger().i(snackbarMessage);
        ShowSnackBar().showSnackBar(context, snackbarMessage!);
      }
    }
  }
}
