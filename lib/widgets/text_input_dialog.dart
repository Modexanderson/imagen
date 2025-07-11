import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> showTextInputDialog({
  required BuildContext context,
  required String title,
  String? initialText,
  required TextInputType keyboardType,
  required Function(String) onSubmitted,
}) async {
  await showDialog(
    context: context,
    builder: (BuildContext ctxt) {
      final controller = TextEditingController(text: initialText);
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
            TextField(
              autofocus: true,
              controller: controller,
              keyboardType: keyboardType,
              textAlignVertical: TextAlignVertical.bottom,
              onSubmitted: (value) {
                onSubmitted(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.grey[900],
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text( AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor:
                  Theme.of(context).colorScheme.secondary == Colors.white
                      ? Colors.black
                      : Colors.white,
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {
              onSubmitted(controller.text.trim());
            },
            child: Text(
              AppLocalizations.of(context)!.ok,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
        ],
      );
    },
  );
}
