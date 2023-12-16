import 'package:flutter/material.dart';
import 'package:imagen/widgets/snack_bar.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RateAppInitWidget extends StatefulWidget {
  final Widget Function(RateMyApp) builder;

  const RateAppInitWidget({
    Key? key,
    required this.builder,
  }) : super(key: key);

  @override
  State<RateAppInitWidget> createState() => _RateAppInitWidgetState();
}

class _RateAppInitWidgetState extends State<RateAppInitWidget> {
  RateMyApp? rateMyApp;
  static const playStoreId = 'com.imagen.android';
  static const appStoreId = '';

  @override
  Widget build(BuildContext context) {
    return RateMyAppBuilder(
      rateMyApp: RateMyApp(
        googlePlayIdentifier: playStoreId,
        appStoreIdentifier: appStoreId,
        minDays: 2,
        minLaunches: 3,
        remindDays: 2,
        remindLaunches: 3,
      ),
      onInitialized: (context, rateMyApp) {
        setState(() => this.rateMyApp = rateMyApp);

        if (rateMyApp.shouldOpenDialog) {
          rateMyApp.showStarRateDialog(
            context,
            title: AppLocalizations.of(context)!.rateImagen,
            message: AppLocalizations.of(context)!.leaveARating,
            starRatingOptions: const StarRatingOptions(initialRating: 5),
            actionsBuilder: actionsBuilder,
          );
        }
      },
      builder: (context) => rateMyApp == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : widget.builder(rateMyApp!),
    );
  }

  List<Widget> actionsBuilder(
    BuildContext context,
    double? stars,
  ) =>
      stars == null
          ? [buildCancelButton()]
          : [
              buildOkButton(stars),
              buildCancelButton(),
            ];

  // Widget buildOkButton(double? stars) => TextButton(
  //       child: const Text('OK'),
  //       onPressed: () async {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //             const SnackBar(content: Text('Thanks for your feedback!')));
  //         final launchAppStore = stars! >= 3;
  //         const event = RateMyAppEventType.rateButtonPressed;
  //         await rateMyApp?.callEvent(event);
  //         if (launchAppStore) {
  //           rateMyApp?.launchStore();
  //         }
  //         Navigator.of(context).pop();
  //       },
  //     );

  Widget buildOkButton(double? stars) => RateMyAppRateButton(
        rateMyApp!,
        text: AppLocalizations.of(context)!.ok,
        callback: () async {
          ShowSnackBar().showSnackBar(context, AppLocalizations.of(context)!.thanksFeedback);
          
          final launchAppStore = stars! >= 3;
          const event = RateMyAppEventType.rateButtonPressed;
          await rateMyApp?.callEvent(event);
          if (launchAppStore) {
            rateMyApp?.launchStore();
          }
          Navigator.of(context).pop();
        },
      );

  Widget buildCancelButton() => RateMyAppNoButton(
        rateMyApp!,
        text: AppLocalizations.of(context)!.cancel,
      );
}
