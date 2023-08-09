import 'package:flutter/material.dart';
import 'package:imagen/home_screen.dart';
import 'package:provider/provider.dart';

import 'constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey.shade900,
        primaryColor: Colors.grey.shade900,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: kPrimaryColor,
        ),
        inputDecorationTheme: const InputDecorationTheme(
            focusColor: kPrimaryColor,
            labelStyle: TextStyle(color: kPrimaryColor),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: kPrimaryColor, width: 2.0),
            )),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: kPrimaryColor),
        appBarTheme: const AppBarTheme(
          color: kPrimaryColor,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        colorScheme: const ColorScheme.dark(),
      ),
      home: const HomeScreen(),
    );
  }
}
