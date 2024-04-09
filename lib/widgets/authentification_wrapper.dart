import 'package:flutter/material.dart';
import 'package:imagen/screens/feed_screen.dart';

import '../screens/home_screen.dart';
import '../screens/sign_in_screen.dart';
import '../services/authentification_service.dart';
import 'rate_app_init_widget.dart';
class AuthentificationWrapper extends StatelessWidget {
  static const String routeName = "/authentification_wrapper";

  const AuthentificationWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthentificationService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return RateAppInitWidget(
        builder: (rateMyApp) => HomeScreen());
        } else {
          return const SignInScreen();
        }
      },
    );
  }
}
