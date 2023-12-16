import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ShowSnackBar {
  void showSnackBar(
    BuildContext context,
    String title, {
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
    bool noAction = false,
  }) {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: duration,
          // margin: EdgeInsets.only(
          //   bottom: MediaQuery.of(context).size.height - 160,
          // ),
          elevation: 6,
          // backgroundColor: const Color(0xFF0A84FF),
          behavior: SnackBarBehavior.floating,
          content: Text(
            title,
            style:  TextStyle(color: Theme.of(context).textTheme.bodySmall!.color),
          ),
          action: noAction
              ? null
              : action ??
                  SnackBarAction(
                    textColor: Theme.of(context).colorScheme.secondary,
                    label: AppLocalizations.of(context)!.ok,
                    onPressed: () {},
                  ),
        ),
      );
    } catch (e) {
      log('Failed to show Snackbar with title:$title');
    }
  }
}
