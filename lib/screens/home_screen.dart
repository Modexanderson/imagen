// ignore_for_file: use_build_context_synchronously

import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gal/gal.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:imagen/l10n/app_localizations.dart';
import 'package:imagen/widgets/credit_alert_dialog.dart';
import 'package:imagen/widgets/default_button.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:upgrader/upgrader.dart';
import 'package:provider/provider.dart';

import '../api/enums.dart';
import '../models/image_info.dart';
import '../providers/image_provider.dart'
    as img_provider; // Renamed to avoid conflict
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
  final uniqueIdentifier = const Uuid().v4();

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

      final imageName = '$truncatedCustomPart$uniqueIdentifier$time.png';

      // Save image using GAL
      await Gal.putImageBytes(imageBytes, name: imageName);

      ShowSnackBar()
          .showSnackBar(context, AppLocalizations.of(context)!.imageSaved);

      if (kDebugMode) {
        print('Image successfully saved to gallery with GAL');
      }

      return imageName; // Return the image name as identifier
    } catch (error) {
      ShowSnackBar().showSnackBar(
          context, AppLocalizations.of(context)!.imageSavedFailed);

      if (kDebugMode) {
        print('Error saving image to gallery with GAL: $error');
      }

      return ''; // Return empty string if saving fails
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

    // Clear cached debit value to get fresh data from Firestore
    clearDebitValueCache();

    // Initialize user credits from cache
    _initializeCachedCredits();
  }

  void clearDebitValueCache() {
    final box = Hive.box('user_data');
    box.delete('debitValue');
    print('Debit value cache cleared');
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

  Future<double> getDebitValue() async {
    final box = Hive.box('user_data');
    final cachedDebitValue = box.get('debitValue');
    final cachedTime = box.get('debitValueTimestamp');

    // Check if cache is still valid (e.g., cache for 1 hour)
    const cacheExpiry = Duration(hours: 1);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (cachedDebitValue != null &&
        cachedTime != null &&
        (now - cachedTime) < cacheExpiry.inMilliseconds) {
      if (kDebugMode) {
        print('Using cached debit value: $cachedDebitValue');
      }
      return cachedDebitValue;
    }

    try {
      if (kDebugMode) {
        print('Fetching fresh debit value from Firestore');
      }

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('debit_collection')
          .doc('debit_doc')
          .get();

      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        double debitValue = (data['debitValue'] ?? 0.0).toDouble();

        // Cache the new value with timestamp
        box.put('debitValue', debitValue);
        box.put('debitValueTimestamp', now);

        if (kDebugMode) {
          print('Fresh debit value cached: $debitValue');
        }

        return debitValue;
      } else {
        if (kDebugMode) {
          print('Document does not exist or debit field is missing.');
        }
        return 0.0;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error retrieving debit value: $e');
      }
      // Return cached value if available, even if expired, as fallback
      return cachedDebitValue ?? 0.0;
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

  final GlobalKey<_HomeScreenState> drawerKey = GlobalKey<_HomeScreenState>();

  void updateDrawer() {
    setState(() {});
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
        AppLocalizations.of(context)!.settings,
      ];

      final Map<String, List> boxNames = {
        AppLocalizations.of(context)!.settings: ['settings'],
        AppLocalizations.of(context)!.imageHistory: ['imageHistory'],
        AppLocalizations.of(context)!.cache: ['cache'],
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
    List<Map<String, dynamic>> paymentOptions = [
      {
        'name': 'Card Payment',
        'image': 'assets/icons/stripe_method.svg',
        'onTap': () {
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
    ];

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
            shouldPopScope: () {
              return true;
            }),
        child: Consumer<img_provider.ImageProvider>(
          builder: (context, imageProvider, child) => Scaffold(
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
                    AppLocalizations.of(context)!.appTitle,
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
                        return const SizedBox(
                            width: 40,
                            child: Center(child: DefaultProgressIndicator()));
                      }

                      if (snapshot.hasError) {
                        return Text(AppLocalizations.of(context)!.error +
                            snapshot.error.toString());
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Text(AppLocalizations.of(context)!.noData);
                      }

                      final Map<String, dynamic>? userData =
                          snapshot.data!.data() as Map<String, dynamic>?;

                      if (userData == null) {
                        return Text(AppLocalizations.of(context)!.nullUserData);
                      }

                      double credits = double.parse(
                          (userData['credits'] ?? 0.0).toStringAsFixed(2));
                      userCredits = credits;
                      Hive.box('user_data').put('credits', credits);

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
                                            const SizedBox(height: 16),
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
                                                      height: 100,
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
                                        context, const RevenueCatPayWidget());
                                  }
                                },
                                credits: credits,
                              );
                            },
                          );
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.monetization_on_outlined,
                                size: 30),
                            const SizedBox(width: 4),
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
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 10),
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
                    // Generate Button
                    if (imageProvider.status !=
                        img_provider.ImageGenerationStatus.loading)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: SizedBox(
                          height: 60,
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: DefaultButton(
                            press: () async {
                              // Prevent multiple simultaneous generations
                              if (!buttonIsEnabled) {
                                return;
                              }

                              // Immediately disable the button to prevent multiple presses
                              setState(() {
                                buttonIsEnabled = false;
                              });

                              try {
                                // Check user verification
                                bool allowed = AuthentificationService()
                                    .currentUserVerified;

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
                                  return;
                                }

                                // Check input
                                if (_textEditingController.text
                                    .trim()
                                    .isEmpty) {
                                  ShowSnackBar().showSnackBar(
                                      context,
                                      AppLocalizations.of(context)!
                                          .inputSomeText);
                                  return;
                                }

                                // Check user credits
                                double debitValue = await getDebitValue();
                                if (userCredits < debitValue) {
                                  ShowSnackBar().showSnackBar(
                                      context,
                                      AppLocalizations.of(context)!
                                          .insufficientCredits);
                                  return;
                                }

                                // Start generation
                                if (kDebugMode) {
                                  print('Starting image generation...');
                                  print(
                                      'Prompt: ${_textEditingController.text}');
                                  print('Style: $_selectedStyle');
                                  print('Resolution: $_selectedResolution');
                                }

                                Uint8List image =
                                    await imageProvider.generateImage(
                                  _textEditingController.text.trim(),
                                  _selectedStyle,
                                  _selectedResolution,
                                );

                                // Handle successful generation
                                if (image.isNotEmpty) {
                                  bool deductionResult =
                                      await UserDatabaseHelper()
                                          .deductCreditsForUser(
                                              userUid, debitValue);

                                  // Save to history
                                  Hive.box('imageHistory').add(HiveImageInfo(
                                      image,
                                      _textEditingController.text.trim(),
                                      DateTime.now()));

                                  if (deductionResult) {
                                    if (kDebugMode) {
                                      print(
                                          'Image generated successfully and credits deducted');
                                    }
                                  } else {
                                    ShowSnackBar().showSnackBar(
                                        context,
                                        AppLocalizations.of(context)!
                                            .insufficientCredits);
                                  }
                                } else {
                                  ShowSnackBar().showSnackBar(
                                      context,
                                      AppLocalizations.of(context)!
                                          .failedGeneration);
                                }
                              } catch (error) {
                                if (kDebugMode) {
                                  print(
                                      'Error during image generation: $error');
                                }
                                ShowSnackBar().showSnackBar(
                                    context,
                                    AppLocalizations.of(context)!
                                        .errorImageGeneration);
                              } finally {
                                // Always re-enable the button
                                if (mounted) {
                                  setState(() {
                                    buttonIsEnabled = true;
                                  });
                                }
                              }
                            },
                            text: AppLocalizations.of(context)!.create,
                          ),
                        ),
                      ),

                    // Image Display Container
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.secondary,
                            width: 2.0,
                          ),
                        ),
                        height: size,
                        width: size,
                        child: _buildImageWidget(imageProvider, size),
                      ),
                    ),

                    // Download Button
                    if (imageProvider.status ==
                            img_provider.ImageGenerationStatus.loaded &&
                        imageProvider.generatedImage != null)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                          height: 60,
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: DefaultButton(
                            press: () {
                              _downloadImage(
                                imageProvider.generatedImage!,
                                _textEditingController.text,
                              );
                            },
                            text: AppLocalizations.of(context)!.download,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(
      img_provider.ImageProvider imageProvider, double size) {
    switch (imageProvider.status) {
      case img_provider.ImageGenerationStatus.loading:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                imageProvider.cancelGeneration();
              },
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(decoration: TextDecoration.underline),
              ),
            )
          ],
        );

      case img_provider.ImageGenerationStatus.loaded:
        if (imageProvider.generatedImage != null) {
          return _buildImageDisplay(imageProvider.generatedImage!);
        }
        return Container();

      case img_provider.ImageGenerationStatus.error:
        if (kDebugMode) {
          print('Image generation error: ${imageProvider.errorMessage}');
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(50.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const DefaultErrorIndicator(),
                Text(
                  AppLocalizations.of(context)!.failedGenerationTryAgain,
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

      case img_provider.ImageGenerationStatus.stopped:
        return Center(
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

      case img_provider.ImageGenerationStatus.initial:
      default:
        return Container();
    }
  }

  Widget _buildImageDisplay(Uint8List image) {
    if (Platform.isAndroid) {
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: FadeInImage(
              placeholder: const AssetImage('assets/images/imagen_black.png'),
              image: MemoryImage(image),
              fit: BoxFit.contain,
            ),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            width: MediaQuery.of(context).size.height * 0.7,
            child: FadeInImage(
              placeholder: const AssetImage('assets/images/imagen_black.png'),
              image: MemoryImage(image),
              fit: BoxFit.contain,
            ),
          ),
        );
      }
    } else {
      if (MediaQuery.of(context).size.width >
          MediaQuery.of(context).size.height) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            width: MediaQuery.of(context).size.height * 0.7,
            child: FadeInImage(
              placeholder: const AssetImage('assets/images/imagen_black.png'),
              image: MemoryImage(image),
              fit: BoxFit.contain,
            ),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: FadeInImage(
                  placeholder:
                      const AssetImage('assets/images/imagen_black.png'),
                  image: MemoryImage(image),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      }
    }
  }
}
