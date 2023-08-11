import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoadingDialogWidget extends StatefulWidget {
  bool isGeneratingImage;
  LoadingDialogWidget({super.key, required this.isGeneratingImage});

  @override
  _LoadingDialogWidgetState createState() => _LoadingDialogWidgetState();
}

class _LoadingDialogWidgetState extends State<LoadingDialogWidget>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      vsync: this,
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset('assets/animations/infinite-loader.json',
              width: MediaQuery.of(context).size.width / 4,
              controller: _lottieController.view),
          const SizedBox(height: 8),
          const Text(
            AppLocalizations.of(context)!.creatingProcess,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } // Dismiss the dialog when cancel button is pressed
              setState(() {
                widget.isGeneratingImage = false;
              });
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }
}
