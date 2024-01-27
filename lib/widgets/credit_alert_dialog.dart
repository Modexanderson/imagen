import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

import 'default_button.dart';

class CreditAlertDialog extends StatefulWidget {
  final double credits;
  final Function press;

  const CreditAlertDialog(
      {Key? key, required this.press, required this.credits})
      : super(key: key);

  @override
  _CreditAlertDialogState createState() => _CreditAlertDialogState();
}

class _CreditAlertDialogState extends State<CreditAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.creditBalance,
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.width * 0.5,
        child:
            Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.monetization_on_outlined, size: 40),
              const SizedBox(
                  width: 4), // Adjust the spacing between icon and credits
              SizedBox(
                // width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$widget.credits',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          DefaultButton(
              text: AppLocalizations.of(context)!.rechargeNow,
              press: widget.press)
        ]),
      ),
    );
  }
}
