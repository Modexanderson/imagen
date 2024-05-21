import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'config.dart';

// ignore: avoid_classes_with_only_static_members
class AppTheme {
  static MyTheme get currentTheme => GetIt.I<MyTheme>();
  static ThemeMode get themeMode => GetIt.I<MyTheme>().currentTheme();
  static ThemeData lightTheme({
    required BuildContext context,
  }) {
    return ThemeData(
      // TextTheme(),
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: currentTheme.currentColor(),
        cursorColor: currentTheme.currentColor(),
        selectionColor: currentTheme.currentColor(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(width: 1.5, color: Colors.black),
        ),
        border: const OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.black), // Set your border color here
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(),
      cardTheme: CardTheme(
        clipBehavior: Clip.antiAlias,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
      ),
      disabledColor: Colors.grey[600],
      brightness: Brightness.light,
      snackBarTheme:
          SnackBarThemeData(backgroundColor: Theme.of(context).cardColor),
      indicatorColor: currentTheme.currentColor(),
      progressIndicatorTheme: const ProgressIndicatorThemeData()
          .copyWith(color: currentTheme.currentColor()),
      iconTheme: IconThemeData(
        color: Colors.grey[900],
        opacity: 1.0,
        size: 24.0,
      ),
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Colors.grey[900],
            brightness: Brightness.light,
            secondary: currentTheme.currentColor(),
          ),
    );
  }

  static ThemeData darkTheme({
    required BuildContext context,
  }) {
    return ThemeData(
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        selectionHandleColor: currentTheme.currentColor(),
        cursorColor: currentTheme.currentColor(),
        selectionColor: currentTheme.currentColor(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: Colors.white),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(width: 1.5, color: Colors.white),
        ),
        border: const OutlineInputBorder(
          borderSide:
              BorderSide(color: Colors.white), // Set your border color here
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: currentTheme.getCanvasColor(),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: Colors.white,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        iconColor: Colors.white,
        textColor: Colors.white,
        collapsedTextColor: Colors.white,
        collapsedIconColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
          color: currentTheme.getCardColor(),
          textStyle: const TextStyle(color: Colors.white),
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            // Default TextStyle
            return const TextStyle(color: Colors.white);
          })),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      brightness: Brightness.dark,
      snackBarTheme:
          SnackBarThemeData(backgroundColor: Theme.of(context).hintColor),
      appBarTheme: AppBarTheme(
        backgroundColor: currentTheme.getCanvasColor(),
        foregroundColor: Colors.white,
      ),
      canvasColor: currentTheme.getCanvasColor(),
      scaffoldBackgroundColor: currentTheme.getCanvasColor(),
      textTheme: Typography.whiteCupertino,
      drawerTheme: DrawerThemeData(
        backgroundColor: currentTheme.getCanvasColor(),
      ),
      cardColor: currentTheme.getCardColor(),
      cardTheme: CardTheme(
        color: currentTheme.getCardColor(),
        clipBehavior: Clip.antiAlias,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
      ),
      dialogBackgroundColor: currentTheme.getCardColor(),
      progressIndicatorTheme: const ProgressIndicatorThemeData()
          .copyWith(color: currentTheme.currentColor()),
      iconTheme: const IconThemeData(
        color: Colors.white,
        opacity: 1.0,
        size: 24.0,
      ),
      indicatorColor: currentTheme.currentColor(),
      colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: Colors.white,
            secondary: currentTheme.currentColor(),
            brightness: Brightness.dark,
          ),
    );
  }
}
