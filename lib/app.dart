import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:path_provider/path_provider.dart';

import 'Pages/home_page.dart';
import 'widgets/app_theme.dart';
import 'widgets/config.dart';
import 'widgets/rate_app_init_widget.dart';

Future<void> openHiveBox(String boxName, {bool limit = false}) async {
  final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dirPath = dir.path;
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      dbFile = File('$dirPath/Imagen/$boxName.hive');
      lockFile = File('$dirPath/Imagen/$boxName.lock');
    }
    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox(boxName);
    throw 'Failed to open $boxName Box\nError: $error';
  });
  // clear box if it grows large
  if (limit && box.length > 500) {
    box.clear();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en', '');

  late StreamSubscription _intentDataStreamSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void dispose() {
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    GetIt.I.registerSingleton<MyTheme>(MyTheme());
    final String lang =
        Hive.box('settings').get('lang', defaultValue: 'English') as String;
    final Map<String, String> codes = {
      'Arabic': 'ar',
      'Chinese': 'zh',
      'Czech': 'cs',
      'Dutch': 'nl',
      'English': 'en',
      'French': 'fr',
      'German': 'de',
      'Hebrew': 'he',
      'Hindi': 'hi',
      'Indonesian': 'id',
      'Portuguese': 'pt',
      'Russian': 'ru',
      'Spanish': 'es',
      'Tamil': 'ta',
      'Turkish': 'tr',
      'Ukrainian': 'uk',
      'Urdu': 'ur',
    };
    _locale = Locale(codes[lang]!);

    AppTheme.currentTheme.addListener(() {
      setState(() {});
    });
  }

  void setLocale(Locale value) {
    setState(() {
      _locale = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppTheme.themeMode == ThemeMode.dark
            ? Colors.black38
            : Colors.white,
        statusBarIconBrightness: AppTheme.themeMode == ThemeMode.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarIconBrightness: AppTheme.themeMode == ThemeMode.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    return MaterialApp(
      title: 'IMAGEN',
      themeMode: AppTheme.themeMode,
      theme: AppTheme.lightTheme(
        context: context,
      ),
      darkTheme: AppTheme.darkTheme(
        context: context,
      ),

      restorationScopeId: 'imagen',
      debugShowCheckedModeBanner: false,
      // theme: ThemeData.dark(),
      home:
          // widget.showHome
          //     ?
          //  RateStarScreen(rateMyApp: rateMyApp)
          RateAppInitWidget(
        builder: (rateMyApp) => const HomePage(),
        // const HomePage(),
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''), // Arabic
        Locale('zh', ''), // Chinese
        Locale('cs', ''), // Czech
        Locale('nl', ''), // Dutch
        Locale('en', ''), // English, no country code
        Locale('fr', ''), // French
        Locale('de', ''), // German
        Locale('he', ''), // Hebrew
        Locale('hi', ''), // Hindi
        Locale('id', ''), // Indonesian
        Locale('pt', ''), // Portuguese
        Locale('ru', ''), // Russian
        Locale('es', ''), // Spanish
        Locale('ta', ''), // Tamil
        Locale('tr', ''), // Turkish
        Locale('uk', ''), // Ukrainian
        Locale('ur', ''), // Urdu
      ],
      navigatorKey: navigatorKey,
      // onGenerateRoute: (RouteSettings settings) {
      //   return HandleRoute.handleRoute(settings.name);
      // },
    );
    // return MultiBlocProvider(
    //   providers: [
    //     BlocProvider(
    //       create: (_) => AppLanguageCubit(const Locale(englishLanguage, 'US'))
    //         ..loadLanguage(),
    //     ),
    //     BlocProvider(
    //       create: (_) => AppThemeCubit(material)..loadTheme(),
    //     ),
    //     BlocProvider(
    //       create: (_) => AppModeCubit(system)..loadMode(),
    //     ),
    //     BlocProvider(
    //       create: (_) => AppDirectoryCubit(pathHint)..loadPath(),
    //     ),
    //   ],
    //   child: BlocBuilder<AppThemeCubit, AppThemeState>(
    //     builder: (context, appTheme) {
    //       return BlocBuilder<AppModeCubit, AppModeState>(
    //         builder: (context, appMode) {
    //           return BlocBuilder<AppLanguageCubit, AppLanguageState>(
    //             builder: (context, language) {
    //               return Shortcuts(
    //                 shortcuts: <LogicalKeySet, Intent>{
    //                   LogicalKeySet(LogicalKeyboardKey.select):
    //                       const ActivateIntent(),
    //                 },
    //                 child: MaterialApp(
    //                   localizationsDelegates:
    //                       AppLocalizations.localizationsDelegates,
    //                   supportedLocales: AppLocalizations.supportedLocales,
    //                   locale: language.locale,
    //                   scrollBehavior: CustomScroll(),
    //                   initialRoute: '/',
    //                   routes: {
    //                     '/': (_) => const HomePage(),
    //                     '/Settings': (_) => const Settings(),
    //                   },
    //                   debugShowCheckedModeBanner: false,
    //                   themeMode: getMode(appMode.mode),
    //                   theme: appTheme.theme.lightTheme,
    //                   darkTheme: appTheme.theme.darkTheme,
    //                 ),
    //               );
    //             },
    //           );
    //         },
    //       );
    //     },
    //   ),
    // );
  }
}

class CustomScroll extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
