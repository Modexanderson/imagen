import 'package:flutter/material.dart';
import 'package:imagen/widgets/snack_bar.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../exceptions/firebase_sign_up_exception.dart';
import '../exceptions/messaged_firebase_auth_exception.dart';
import '../models/constants.dart';
import '../models/size_config.dart';
import '../services/authentification_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/database/user_database_helper.dart';
import 'async_progress_dialog.dart';
import 'default_button.dart';
import 'default_text_form_field.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool isPasswordVisible = false;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailFieldController = TextEditingController();
  final TextEditingController passwordFieldController = TextEditingController();
  final TextEditingController confirmPasswordFieldController =
      TextEditingController();

  @override
  void dispose() {
    emailFieldController.dispose();
    passwordFieldController.dispose();
    confirmPasswordFieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: getProportionateScreenWidth(screenPadding)),
        child: Column(
          children: [
            buildEmailFormField(),
            SizedBox(height: getProportionateScreenHeight(30)),
            buildPasswordFormField(),
            SizedBox(height: getProportionateScreenHeight(30)),
            buildConfirmPasswordFormField(),
            SizedBox(height: getProportionateScreenHeight(40)),
            DefaultButton(
              text: AppLocalizations.of(context)!.signUp,
              press: signUpButtonCallback,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildConfirmPasswordFormField() {
    return DefaultTextFormField(
      controller: confirmPasswordFieldController,
      obscureText: !isPasswordVisible,
      
        hintText: AppLocalizations.of(context)!.reenterPassword,
        labelText: AppLocalizations.of(context)!.confirmPassword,
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
      validator: (value) {
        if (confirmPasswordFieldController.text.isEmpty) {
          return AppStrings.getPassNullError(context);
        } else if (confirmPasswordFieldController.text !=
            passwordFieldController.text) {
          return AppStrings.getMatchPassError(context);
        } else if (confirmPasswordFieldController.text.length < 8) {
          return AppStrings.getShortPassError(context);
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget buildEmailFormField() {
    return DefaultTextFormField(
      controller: emailFieldController,
      keyboardType: TextInputType.emailAddress,
          hintText: AppLocalizations.of(context)!.enterEmail,
          labelText: AppLocalizations.of(context)!.email,
          suffixIcon: const Icon(Icons.mail),
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

  Widget buildPasswordFormField() {
    return DefaultTextFormField(
      controller: passwordFieldController,
      obscureText: !isPasswordVisible,
      
        hintText: AppLocalizations.of(context)!.enterPassword,
        labelText: AppLocalizations.of(context)!.password,
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

  // Future<void> signUpButtonCallback() async {
  //   if (_formKey.currentState!.validate()) {
  //     // goto complete profile page
  //     final AuthentificationService authService = AuthentificationService();
  //     bool signUpStatus = false;
  //     String? snackbarMessage;
  //     try {
  //       final signUpFuture = authService.signUp(
  //         email: emailFieldController.text,
  //         password: passwordFieldController.text,
  //       );

  //       signUpFuture.then((value) {
  //         print('Value from signUpFuture: $value');
  //         signUpStatus = value;
  //       });
  //       signUpStatus = await showDialog(
  //         context: context,
  //         builder: (context) {
  //           return AsyncProgressDialog(
  //             signUpFuture,
  //             message: Text(AppLocalizations.of(context)!.creatingNewAccount),
  //           );
  //         },
  //       );
  //       if (signUpStatus == true) {
  //         snackbarMessage =
  //             AppLocalizations.of(context)!.successfulRegistration;
  //       } else {
  //         throw FirebaseSignUpAuthUnknownReasonFailureException();
  //       }
  //     } on MessagedFirebaseAuthException catch (e) {
  //       snackbarMessage = e.message;
  //     } catch (e) {
  //       snackbarMessage = e.toString();
  //     } finally {
  //       Logger().i(snackbarMessage);
  //       ShowSnackBar().showSnackBar(context, snackbarMessage!);

  //       if (signUpStatus == true) {
  //         Navigator.pop(context);
  //       }
  //     }
  //   }
  // }
  Future<void> signUpButtonCallback() async {
    if (_formKey.currentState!.validate()) {
      final AuthentificationService authService = AuthentificationService();
      bool signUpStatus = false;
      String? snackbarMessage;

      try {
        signUpStatus = await showDialog(
          context: context,
          builder: (context) {
            return AsyncProgressDialog(
              authService.signUp(
                email: emailFieldController.text,
                password: passwordFieldController.text,
              ),
              message: Text(AppLocalizations.of(context)!.creatingNewAccount),
            );
          },
        );

        if (signUpStatus == true) {
          snackbarMessage =
              AppLocalizations.of(context)!.successfulRegistration;
        } else {
          throw FirebaseSignUpAuthUnknownReasonFailureException();
        }
      } on MessagedFirebaseAuthException catch (e) {
        snackbarMessage = e.message;
      } catch (e) {
        snackbarMessage = e.toString();
        throw FirebaseSignUpAuthUnknownReasonFailureException(
            message: snackbarMessage);
      } finally {
        Logger().i(snackbarMessage);
        ShowSnackBar().showSnackBar(context, snackbarMessage!);

        if (signUpStatus == true) {
          Navigator.pop(context);
        }
      }
    }
  }
}
