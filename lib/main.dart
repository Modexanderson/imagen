import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'models/.env.dart';
import 'models/image_info.dart';
import 'widgets/binance_pay_widget.dart';
import 'widgets/stripe_pay_widget.dart';
import 'widgets/revenue_cat_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.remove();
  
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await Hive.initFlutter('Imagen');
  } else {
    await Hive.initFlutter();
  }
  
  Hive.registerAdapter(HiveImageInfoAdapter());
  await openHiveBox('settings');
  await openHiveBox('imageHistory');
  await openHiveBox('cache', limit: true);

  if (Platform.isAndroid) {
    // setOptimalDisplayMode();
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();
  // await PurchaseApi.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BinancePayState()),
        ChangeNotifierProvider(create: (context) => RenenueCatState()),
        ChangeNotifierProvider(create: (context) => StripePayState()),
        // Add other providers as needed
      ],
      child: const MyApp(),
    ),
  );
}
