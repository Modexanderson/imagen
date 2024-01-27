import 'package:flutter/material.dart';
import 'package:imagen/widgets/snack_bar.dart';
import 'package:logger/logger.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../exceptions/credential_actions_exception.dart';
import '../exceptions/messaged_firebase_auth_exception.dart';
import '../models/constants.dart';
import '../models/size_config.dart';
import '../services/authentification_service.dart';
import 'async_progress_dialog.dart';
import 'default_button.dart';
import 'default_text_form_field.dart';
import 'no_account_text.dart';

class ForgotPasswordForm extends StatefulWidget {
  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailFieldController = TextEditingController();
  @override
  void dispose() {
    emailFieldController.dispose();
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
            SizedBox(height: SizeConfig.screenHeight! * 0.1),
            DefaultButton(
              text: AppLocalizations.of(context)!.sendVerificationEmail,
              press: sendVerificationEmailButtonCallback,
            ),
            SizedBox(height: SizeConfig.screenHeight! * 0.1),
            const NoAccountText(),
            SizedBox(height: getProportionateScreenHeight(30)),
          ],
        ),
      ),
    );
  }

  DefaultTextFormField buildEmailFormField() {
    return DefaultTextFormField(
      controller: emailFieldController,
      keyboardType: TextInputType.emailAddress,
      hintText: AppLocalizations.of(context)!.enterEmail,
      labelText: AppLocalizations.of(context)!.email,
      suffixIcon: const Icon(
        Icons.mail,
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return AppStrings.getEmailNullError(context);
          
        } else if (!emailValidatorRegExp.hasMatch(value)) {
          return AppStrings.getInvalidEmailError(context);
        }
        return null;
      },
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Future<void> sendVerificationEmailButtonCallback() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final String emailInput = emailFieldController.text.trim();
      bool resultStatus;
      String? snackbarMessage;
      try {
        final resultFuture =
            AuthentificationService().resetPasswordForEmail(context, emailInput);
        resultFuture.then((value) => resultStatus = value);
        resultStatus = await showDialog(
          context: context,
          builder: (context) {
            return AsyncProgressDialog(
              resultFuture,
              // message:
              //     Text(AppLocalizations.of(context)!.sendingVerificationEmail),
            );
          },
        );
        if (resultStatus == true) {
          snackbarMessage = AppLocalizations.of(context)!.passwordResetLink;
        } else {
          throw FirebaseCredentialActionAuthUnknownReasonFailureException(
              message: AppLocalizations.of(context)!.sorryRequestProcess);
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
