// ignore_for_file: use_build_context_synchronously

import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:imagen/widgets/credit_alert_dialog.dart';
import 'package:imagen/widgets/default_button.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:upgrader/upgrader.dart';
import '../api/enums.dart';
import '../api/purchase_api.dart';
import '../bloc/image_cubit.dart';

import '../models/image_info.dart';
import '../services/authentification_service.dart';
import '../services/database/user_database_helper.dart';
import '../services/ext_storage_provider.dart';
import '../utils/backup_restore.dart';
import '../widgets/binance_pay_widget.dart';
import '../widgets/default_error_indicator.dart';
import '../widgets/default_progress_indicator.dart';
import '../widgets/default_text_form_field.dart';
import '../widgets/drawer.dart';
import '../widgets/planet_spinner_animation.dart';
// import '../widgets/revenue_cat_widget.dart';
import '../widgets/revenue_cat_widget.dart';
import '../widgets/show_confirmation_dialog.dart';
import '../widgets/snack_bar.dart';
import '../widgets/stripe_pay_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ImageCubit _imageCubit;
  double userCredits = 0.0;
  String _appVersion = '';
  final TextEditingController _textEditingController = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<AIStyle, String> formattedStyleText = {
    AIStyle.noStyle: 'no style',
    AIStyle.kandinskyPainter: 'Kadinsky Painter',
    AIStyle.render3D: '3D render',
    AIStyle.anime: 'anime',
    AIStyle.moreDetails: 'More Detailed',
    AIStyle.cyberPunk: 'Cyber Punk',
    AIStyle.cartoon: 'Cartoon',
    AIStyle.picassoPainter: 'Picasso Painter',
    AIStyle.oilPainting: 'Oil Painting',
    AIStyle.digitalPainting: 'Digital Painting',
    AIStyle.portraitPhoto: 'Portrait Photo',
    AIStyle.pencilDrawing: 'Pencil Drawing',
    AIStyle.aivazovskyPainter: 'Alvazovsky Painter',
    AIStyle.studioPhoto: 'Studio Photo',
    AIStyle.christmas: 'Christmas Style',
    AIStyle.classicism: 'Classicism',
    AIStyle.medievalStyle: 'Medival Style',
    AIStyle.renaissance: 'Renaissance',
    AIStyle.goncharovaPainter: 'Goncharova Painter',
    AIStyle.malevichPainter: 'Malevich Painter',
    AIStyle.khokhlomaPainter: 'Khokhloma Painter',
  };
  final Map<Resolution, String> formattedResolution = {
    Resolution.r16x9: '1024 x 576',
    Resolution.r1x1: '1024 x 1024',
    Resolution.r2x3: '680 x 1024',
    Resolution.r3x2: '1024 x 680',
    Resolution.r9x16: '576 x 1024',
  };

  var _selectedStyle = AIStyle.noStyle;
  var _selectedResolution = Resolution.r1x1;
  // Generate a unique identifier instead of using the entire customPart_
  final uniqueIdentifier =
      const Uuid().v4(); // You need to import the uuid package
  Future<String> _downloadImage(
    Uint8List imageBytes,
    String customPart_,
  ) async {
    try {
      DateTime now = DateTime.now();
      int year = now.year;
      int month = now.month;
      int day = now.day;
      int hour = now.hour;
      int minute = now.minute;
      int second = now.second;
      final time = '$year-$month-$day $hour:$minute:$second';

      // Truncate customPart_ to a certain length (e.g., 10 characters)
      final truncatedCustomPart =
          customPart_.length > 10 ? customPart_.substring(0, 10) : customPart_;

      final imageName = '$truncatedCustomPart$uniqueIdentifier$time';

      final result =
          await ImageGallerySaver.saveImage(imageBytes, name: imageName);

      if (result['isSuccess']) {
        ShowSnackBar()
            .showSnackBar(context, AppLocalizations.of(context)!.imageSaved);
        // Image saved successfully
        if (kDebugMode) {
          print('Image successfully saved to gallery');
        }
        return result['filePath'] ?? ''; // Return the file path
      } else {
        ShowSnackBar().showSnackBar(
            context, AppLocalizations.of(context)!.imageSavedFailed);
        // Image save failed
        if (kDebugMode) {
          print('Failed to save image to gallery');
        }
        return ''; // Return an empty string if saving fails
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error saving image to gallery: $error');
      }
      rethrow; // Rethrow the error
    }
  }

  Future<void> _getAppVersion() async {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final String appVersion = packageInfo.version;

    setState(() {
      _appVersion = appVersion;
    });
  }

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _imageCubit = ImageCubit();
    // Revenue cat
    // fetchOffers(context);

    // Initialize user credits from cache
    _initializeCachedCredits();
  }

  String userUid = AuthentificationService().currentUser.uid;

  void _initializeCachedCredits() async {
    final cachedCredits = await _fetchCachedCredits();
    setState(() {
      userCredits = cachedCredits;
    });
  }

  Future<double> _fetchCachedCredits() async {
    final cachedCredits = Hive.box('user_data').get('credits');
    return cachedCredits ?? 0.0;
  }

//   Future<double> _fetchUserCredits() async {
//   final cachedCredits = Hive.box('user_data').get('credits');
//   if (cachedCredits != null) {
//     return cachedCredits; // Use cached value if available
//   }

//   try {
//     // Fetch credits from Firestore if not cached
//     final documentSnapshot = await UserDatabaseHelper().getUserData(userUid);
//     if (documentSnapshot.exists && documentSnapshot.data() != null) {
//       final data = documentSnapshot.data() as Map<String, dynamic>;
//       final credits = data[UserDatabaseHelper.CREDITS] ?? 0.0;
//       Hive.box('user_data').put('credits', credits);
//       return credits;
//     } else {
//       return 0.0; // handle default value
//     }
//   } catch (e) {
//     print('Error fetching user credits: $e');
//     return 0.0; // handle default value
//   }
// }

  Future<double> getDebitValue() async {
    final box = Hive.box('user_data');
    final cachedDebitValue = box.get('debitValue');

    if (cachedDebitValue != null) {
      return cachedDebitValue;
    }

    try {
      // Retrieve the document from Firestore
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('debit_collection')
          .doc('debit_doc')
          .get();

      // Check if the document exists and contains the 'debitValue' field
      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        // Explicitly cast the data to Map<String, dynamic>
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        // Retrieve the debit value
        double debitValue = (data['debitValue'] ?? 0.0).toDouble();

        // Cache the debit value in Hive
        box.put('debitValue', debitValue);

        return debitValue;
      } else {
        if (kDebugMode) {
          print('Document does not exist or debit field is missing.');
        }
        return 0.0; // or handle the default value appropriately
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving debit value: $e');
      }
      return 0.0; // or handle the default value appropriately
    }
  }

  Stream<DocumentSnapshot<Object?>> getUserDataStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .snapshots();
  }

  @override
  void dispose() {
    _imageCubit.close();
    _textEditingController.dispose();
    super.dispose();
  }

  void showPaymentOptions(BuildContext context, dynamic widget) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(child: widget);
        });
  }

  void showPaymentDialog(BuildContext context, dynamic widget) {
    showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return widget;
        });
  }

  List<Package> packages = [];

  // Future fetchOffers(BuildContext context) async {
  //   final offerings = await PurchaseApi.fetchOffersByIds(Coins.allIds);

  //   if (offerings.isEmpty) {
  //     ShowSnackBar()
  //         .showSnackBar(context, AppLocalizations.of(context)!.noPlansFound);
  //   } else {
  //     packages = offerings
  //         .map((offer) => offer.availablePackages)
  //         .expand((pair) => pair)
  //         .toList();
  //   }
  // }

  final GlobalKey<_HomeScreenState> drawerKey = GlobalKey<_HomeScreenState>();

  void updateDrawer() {
    setState(() {}); // Trigger a rebuild of the drawer
  }

  void setPrompt(String prompt) {
    _textEditingController.text = prompt;
  }

  bool buttonIsEnabled = true;
  bool autoBackup =
      Hive.box('settings').get('autoBackup', defaultValue: false) as bool;

  Widget checkBackup() {
    if (autoBackup) {
      final List<String> checked = [
        AppLocalizations.of(
          context,
        )!
            .settings,
      ];

      final Map<String, List> boxNames = {
        AppLocalizations.of(
          context,
        )!
            .settings: ['settings'],
        AppLocalizations.of(
          context,
        )!
            .imageHistory: ['imageHistory'],
        AppLocalizations.of(
          context,
        )!
            .cache: ['cache'],
      };
      final String autoBackPath = Hive.box('settings').get(
        'autoBackPath',
        defaultValue: '',
      ) as String;
      if (autoBackPath == '') {
        ExtStorageProvider.getExtStorage(
          dirName: 'Imagen/Backups',
        ).then((value) {
          Hive.box('settings').put('autoBackPath', value);
          createBackup(
            context,
            checked,
            boxNames,
            path: value,
            fileName: 'Imagen_AutoBackup',
            showDialog: false,
          );
        });
      } else {
        createBackup(
          context,
          checked,
          boxNames,
          path: autoBackPath,
          fileName: 'Imagen_AutoBackup',
          showDialog: false,
        );
      }
    }

    // downloadChecker();
    return const SizedBox();
  }

  DateTime? backButtonPressTime;
  Future<bool> handleWillPop(BuildContext context) async {
    final now = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        backButtonPressTime == null ||
            now.difference(backButtonPressTime!) > const Duration(seconds: 3);

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      backButtonPressTime = now;
      ShowSnackBar().showSnackBar(
        context,
        AppLocalizations.of(context)!.exitConfirm,
        duration: const Duration(seconds: 2),
        noAction: true,
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? image;

    List<Map<String, dynamic>> paymentOptions = [
      {
        'name': 'Card Payment',
        'image': 'assets/icons/stripe_method.svg',
        'onTap': () {
          // print(packages);
          // showPaymentDialog(context, revenueCatWidget(packages));
          showPaymentDialog(context, stripePayWidget());
        },
      },

      {
        'name': 'Binance Pay',
        'image': 'assets/icons/binancePay_method.svg',
        'onTap': () {
          showPaymentDialog(context, binancePayWidget());
        }
      },
      // Add more payment options as needed
    ];

    /// The size of the container for the generated image.
    final double size = Platform.isAndroid || Platform.isIOS
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height / 2;

    return WillPopScope(
      onWillPop: () => handleWillPop(context),
      child: UpgradeAlert(
        upgrader: Upgrader(
            showIgnore: false,
            showLater: false,
            durationUntilAlertAgain: const Duration(days: 1),
            dialogStyle: Platform.isIOS
                ? UpgradeDialogStyle.cupertino
                : UpgradeDialogStyle.material,
            // canDismissDialog: true,
            shouldPopScope: () {
              return true;
            }),
        child: BlocProvider(
          create: (context) => _imageCubit,
          child: Scaffold(
            key: scaffoldKey,
            drawer: AppDrawer(
              appVersion: _appVersion,
              setPromptCallback: setPrompt,
              key: drawerKey,
            ),
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(
                      context,
                    )!
                        .appTitle,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Alva',
                    ),
                  ),
                  StreamBuilder<DocumentSnapshot>(
                    stream: getUserDataStream(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // While waiting for data, you can show a loading indicator or a default value.
                        return const SizedBox(
                            width: 40,
                            child: Center(child: DefaultProgressIndicator()));
                      }

                      if (snapshot.hasError) {
                        // If there's an error, you can display an error message.
                        return Text(AppLocalizations.of(context)!.error +
                            snapshot.error.toString());
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        // If there's no data or the document doesn't exist, handle it accordingly.
                        return Text(AppLocalizations.of(context)!.noData);
                      }

                      // Cast the data to Map<String, dynamic>
                      final Map<String, dynamic>? userData =
                          snapshot.data!.data() as Map<String, dynamic>?;

                      if (userData == null) {
                        return Text(AppLocalizations.of(context)!.nullUserData);
                      }

                      // Update the credits from Firestore
                      double credits = double.parse(
                          (userData['credits'] ?? 0.0).toStringAsFixed(2));
                      userCredits = credits;
                      Hive.box('user_data')
                          .put('credits', credits); // Update the cache

                      return GestureDetector(
                        onTap: () {
                          showCupertinoDialog(
                            barrierDismissible: true,
                            context: context,
                            builder: (context) {
                              return CreditAlertDialog(
                                press: () {
                                  Navigator.pop(context);
                                  if (!(Platform.isIOS || Platform.isMacOS)) {
                                    showPaymentOptions(
                                      context,
                                      Container(
                                        constraints: BoxConstraints(
                                          maxHeight: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.75,
                                        ),
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .selectPayment,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            const Divider(),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              primary: false,
                                              itemCount: paymentOptions.length,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return InkWell(
                                                  onTap: () async {
                                                    paymentOptions[index]
                                                        ['onTap']();
                                                  },
                                                  child: Card(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    margin:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Container(
                                                      height:
                                                          100, // Adjust the height as needed
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Center(
                                                        child: SvgPicture.asset(
                                                            paymentOptions[
                                                                    index]
                                                                ['image']),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const Divider(),
                                          ],
                                        ),
                                      ),
                                    );
                                  } else {
                                    showPaymentDialog(
                                        context, RevenueCatPayWidget());
                                  }
                                },
                                credits: credits,
                              );
                            },
                          );
                        },
                        child: Row(
                          children: [
                            // Replace the text with an icon (e.g., Icons.monetization_on)
                            const Icon(Icons.monetization_on_outlined,
                                size: 30),
                            const SizedBox(
                                width:
                                    4), // Adjust the spacing between icon and credits
                            SizedBox(
                              width: 40,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  '$credits',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    checkBackup(),

                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DefaultTextFormField(
                        controller: _textEditingController,
                        hintText:
                            AppLocalizations.of(context)!.enterPromptExample,
                        labelText: AppLocalizations.of(context)!.enterPrompt,
                        validator: (value) {
                          if (_textEditingController.text.isEmpty) {
                            return AppLocalizations.of(context)!.inputSomeText;
                          }
                          return null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.imageStyle,
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            DropdownButton(
                              value: _selectedStyle,
                              underline: const SizedBox(),
                              items: formattedStyleText.entries
                                  .map((entry) => DropdownMenuItem<AIStyle>(
                                        value: entry.key,
                                        child: Text(entry.value),
                                      ))
                                  .toList(),
                              onChanged: (AIStyle? newValue) {
                                setState(() {
                                  _selectedStyle = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.resolution,
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            DropdownButton(
                              value: _selectedResolution,
                              underline: const SizedBox(),
                              items: formattedResolution.entries
                                  .map((entry) => DropdownMenuItem<Resolution>(
                                        value: entry.key,
                                        child: Text(entry.value),
                                      ))
                                  .toList(),
                              onChanged: (Resolution? newValue) {
                                setState(() {
                                  _selectedResolution = newValue!;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    BlocBuilder<ImageCubit, ImageState>(
                        builder: (context, state) {
                      if (state is ImageLoading) {
                        const SizedBox();
                      } else {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: DefaultButton(
                              press: () async {
                                bool allowed = AuthentificationService()
                                    .currentUserVerified;
                                // Immediately disable the button to prevent multiple presses:
                                buttonIsEnabled = false;

                                // Check user verification (if applicable):
                                if (!allowed) {
                                  final reverify = await showConfirmationDialog(
                                    context,
                                    AppLocalizations.of(context)!
                                        .emailVerificationMessage,
                                    positiveResponse:
                                        AppLocalizations.of(context)!
                                            .resendVerificationEmail,
                                    negativeResponse:
                                        AppLocalizations.of(context)!.goBack,
                                  );

                                  if (reverify) {
                                    try {
                                      bool verificationResult =
                                          await AuthentificationService()
                                              .sendVerificationEmailToCurrentUser();

                                      if (verificationResult) {
                                        ShowSnackBar().showSnackBar(
                                            context,
                                            AppLocalizations.of(context)!
                                                .verificationEmailSuccessful);
                                      } else {
                                        ShowSnackBar().showSnackBar(
                                            context,
                                            AppLocalizations.of(context)!
                                                .sendingVerificationEmailFailed);
                                      }
                                    } catch (error) {
                                      // Handle other exceptions
                                      if (kDebugMode) {
                                        print(
                                            'Error during email verification: $error');
                                      }
                                      ShowSnackBar().showSnackBar(
                                          context,
                                          AppLocalizations.of(context)!
                                              .verificationEmailError);
                                    }
                                  }
                                  return; // Exit if user needs to verify email
                                }

                                // Check input:
                                if (_textEditingController.text.isEmpty) {
                                  ShowSnackBar().showSnackBar(
                                      context,
                                      AppLocalizations.of(context)!
                                          .inputSomeText);
                                  buttonIsEnabled =
                                      true; // Re-enable button after error message
                                  return;
                                }

                                // Display loading indicator:
                                setState(() {
                                  state is ImageLoading;
                                });

                                try {
                                  double debitValue = await getDebitValue();

                                  // Check user credits (if applicable):
                                  if (userCredits < debitValue) {
                                    ShowSnackBar().showSnackBar(
                                        context,
                                        AppLocalizations.of(context)!
                                            .insufficientCredits);
                                    buttonIsEnabled =
                                        true; // Re-enable button after error message
                                    return;
                                  }

                                  // Generate image:
                                  Uint8List image = await _imageCubit.generate(
                                    _textEditingController.text,
                                    _selectedStyle,
                                    _selectedResolution,
                                  );

                                  // Add the generated image to the history list
                                  // imageHistory.add(image);
                                  drawerKey.currentState?.updateDrawer();

                                  // Handle successful image generation (if applicable):
                                  if (image.isNotEmpty) {
                                    bool deductionResult =
                                        await UserDatabaseHelper()
                                            .deductCreditsForUser(
                                                userUid, debitValue);
                                    // Save image to Hive
                                    // Save image information to Hive
                                    Hive.box('imageHistory').add(HiveImageInfo(
                                        image,
                                        _textEditingController.text,
                                        DateTime.now()));

                                    if (deductionResult) {
                                      // Handle successful image generation and credit deduction
                                      // (display image, perform other actions)
                                    } else {
                                      // Handle insufficient credits after image generation
                                      ShowSnackBar().showSnackBar(
                                          context,
                                          AppLocalizations.of(context)!
                                              .insufficientCredits);
                                    }
                                  } else {
                                    // Handle failed image generation
                                    ShowSnackBar().showSnackBar(
                                        context,
                                        AppLocalizations.of(context)!
                                            .failedGeneration);
                                  }
                                } catch (error) {
                                  // Handle other image generation errors
                                  if (kDebugMode) {
                                    print(
                                        'Error during image generation: $error');
                                  }
                                  ShowSnackBar().showSnackBar(
                                      context,
                                      AppLocalizations.of(context)!
                                          .errorImageGeneration);
                                } finally {
                                  // Re-enable button after completing any actions:
                                  buttonIsEnabled = true;
                                }
                              },
                              text: AppLocalizations.of(context)!.create,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    }),
                    // : const SizedBox(),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary, // Set the border color
                            width: 2.0, // Set the border width
                          ),
                        ),
                        height: size,
                        width: size,
                        child: BlocBuilder<ImageCubit, ImageState>(
                          builder: (context, state) {
                            if (state is ImageLoading) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const PlanetSpinnerAnimation(),
                                  Text(
                                    '${AppLocalizations.of(context)!.generatingImage}...',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                      onPressed: () {
                                        context
                                            .read<ImageCubit>()
                                            .cancelGeneration();
                                        //
                                      },
                                      child: Text(
                                        AppLocalizations.of(context)!.cancel,
                                        style: const TextStyle(
                                            decoration:
                                                TextDecoration.underline),
                                      ))
                                ],
                              );
                            } else if (state is ImageStopped) {
                              const SizedBox();
                            } else if (state is ImageLoaded) {
                              image = state.image;

                              if (Platform.isAndroid) {
                                if (MediaQuery.of(context).orientation ==
                                    Orientation.portrait) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: FadeInImage(
                                        placeholder: const AssetImage(
                                            'assets/images/imagen_black.png'),
                                        image: MemoryImage(image!),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.7,
                                      child: FadeInImage(
                                        placeholder: const AssetImage(
                                            'assets/images/imagen_black.png'),
                                        image: MemoryImage(image!),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                if (MediaQuery.of(context).size.width >
                                    MediaQuery.of(context).size.height) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: SizedBox(
                                      width:
                                          MediaQuery.of(context).size.height *
                                              0.7,
                                      child: FadeInImage(
                                        placeholder: const AssetImage(
                                            'assets/images/imagen_black.png'),
                                        image: MemoryImage(image!),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          child: FadeInImage(
                                            placeholder: const AssetImage(
                                                'assets/images/imagen_black.png'),
                                            image: MemoryImage(image!),
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              }
                            } else if (state is ImageError) {
                              final error = state.error;
                              if (kDebugMode) {
                                print(error);
                              }
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(50.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    // crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const DefaultErrorIndicator(),
                                      // SizedBox(height: 10,),
                                      Text(
                                        AppLocalizations.of(context)!
                                            .failedGenerationTryAgain,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return Container();
                          },
                        ),
                      ),
                    ),
                    BlocBuilder<ImageCubit, ImageState>(
                      builder: (context, state) {
                        if (state is ImageLoaded) {
                          image = state.image;

                          if (image != null) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: SizedBox(
                                height: 60,
                                width: MediaQuery.of(context).size.width * 0.9,
                                child: DefaultButton(
                                  press: () {
                                    _downloadImage(
                                      image!,
                                      _textEditingController.text,
                                    );
                                  },
                                  text: AppLocalizations.of(context)!.download,
                                ),
                              ),
                            );
                          } else {
                            // Handle the case where 'image' is null
                            return const SizedBox();
                          }
                        }
                        return const SizedBox();
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
