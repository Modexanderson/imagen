import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import '../models/constants.dart';
import '../models/size_config.dart';
import '../widgets/forgot_password_form.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  static const String routeName = "/forgot_password";
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
          ),
          onPressed: Navigator.of(context).pop,
        ),
      ),
      body: SafeArea(
      child: SingleChildScrollView(
        
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(screenPadding)),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(height: SizeConfig.screenHeight! * 0.04),
                Text(AppLocalizations.of(context)!.forgotPassword,
                  style: headingStyle,
                ),
                Text(
                  AppLocalizations.of(context)!.pleaseEnterMailForReturnLink,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: SizeConfig.screenHeight! * 0.1),
                ForgotPasswordForm(),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}