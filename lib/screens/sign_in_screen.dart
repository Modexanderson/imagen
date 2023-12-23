import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../exceptions/firebase_sign_up_exception.dart';
import '../exceptions/messaged_firebase_auth_exception.dart';
import '../models/constants.dart';
import '../models/size_config.dart';
import '../services/authentification_service.dart';
import '../widgets/async_progress_dialog.dart';
import '../widgets/no_account_text.dart';
import '../widgets/sign_in_form.dart';
import '../widgets/snack_bar.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final AuthentificationService authService = AuthentificationService();

  Future<void> signUpWithGoogleCallback(BuildContext context) async {
    final AuthentificationService authService = AuthentificationService();
    bool signUpStatus = false;
    String? snackbarMessage;
    try {
      final signUpFuture = authService.signUpWithGoogle();
      signUpFuture.then((value) {
        print('Value from signUpFuture: $value');
        signUpStatus = value;
      });
      signUpStatus = await showDialog(
        context: context,
        builder: (context) {
          return AsyncProgressDialog(
            signUpFuture,
            message: Text(AppLocalizations.of(context)!.signInProcess),
          );
        },
      );

      if (signUpStatus == true) {
      } else {
        throw FirebaseSignUpAuthUnknownReasonFailureException();
      }
    } on MessagedFirebaseAuthException catch (e) {
      ShowSnackBar().showSnackBar(context, e.message);
    } catch (e) {
      ShowSnackBar().showSnackBar(context, e.toString());
    } finally {
      Logger().i(snackbarMessage);
      ShowSnackBar().showSnackBar(context, snackbarMessage!);

      if (signUpStatus == true) {
        Navigator.pop(context);
      }
    }
  }


  Future<void> signUpWithAppleCallback(BuildContext context) async {
    final AuthentificationService authService = AuthentificationService();
    bool signUpStatus = false;
    String? snackbarMessage;
    try {
      final signUpFuture = authService.signUpWithApple();
      signUpFuture.then((value) {
        print('Value from signUpFuture: $value');
        signUpStatus = value;
      });
      signUpStatus = await showDialog(
        context: context,
        builder: (context) {
          return AsyncProgressDialog(
            signUpFuture,
            message: Text(AppLocalizations.of(context)!.signInProcess),
          );
        },
      );

      if (signUpStatus == true) {
      } else {
        throw FirebaseSignUpAuthUnknownReasonFailureException();
      }
    } on MessagedFirebaseAuthException catch (e) {
      ShowSnackBar().showSnackBar(context, e.message);
    } catch (e) {
      ShowSnackBar().showSnackBar(context, e.toString());
    } finally {
      Logger().i(snackbarMessage);
      ShowSnackBar().showSnackBar(context, snackbarMessage!);

      if (signUpStatus == true) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(screenPadding)),
          child: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  SizedBox(height: SizeConfig.screenHeight! * 0.04),
                  Text(
                    AppLocalizations.of(context)!.welcomeBack,
                    style: headingStyle,
                  ),
                  Text(
                    AppLocalizations.of(context)!.signInWIthPasswordAndEmail,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: SizeConfig.screenHeight! * 0.08),
                  SignInForm(),
                  SizedBox(height: SizeConfig.screenHeight! * 0.02),
                  const NoAccountText(),
                  SizedBox(height: getProportionateScreenHeight(10)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        height: 1,
                        width: MediaQuery.of(context).size.width /
                            2.5, // Adjust the length of each line segment
                        color: Colors.grey, // Adjust the color as needed
                      ),
                      const SizedBox(
                          width: 5), // Adjust spacing between line and text
                      Text(
                        AppLocalizations.of(context)!.or.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16, // Adjust the font size as needed
                        ),
                      ),
                      const SizedBox(
                          width: 5), // Adjust spacing between line and text
                      Container(
                        height: 1,
                        width: MediaQuery.of(context).size.width /
                            2.5, // Adjust the length of each line segment
                        color: Colors.grey, // Adjust the color as needed
                      ),
                    ],
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                  SignInButton(
                    Buttons.google,
                    text: AppLocalizations.of(context)!.continueWithGoogle,
                    onPressed: () {
                      signUpWithGoogleCallback(context);
                    },
                  ),
                  SizedBox(height: getProportionateScreenHeight(5)),
                  SignInButton(
                    Buttons.apple,
                    text: AppLocalizations.of(context)!.continueWithApple,
                    onPressed: () {
                      signUpWithAppleCallback(context);
                    },
                  ),
                  SizedBox(height: getProportionateScreenHeight(20)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
