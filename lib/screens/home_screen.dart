// ignore_for_file: use_build_context_synchronously

import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:imagen/widgets/default_button.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:upgrader/upgrader.dart';
import '../api/enums.dart';
import '../api/purchase_api.dart';
import '../bloc/image_cubit.dart';

import '../services/authentification_service.dart';
import '../services/database/user_database_helper.dart';
import '../widgets/async_progress_dialog.dart';
import '../widgets/binance_pay_widget.dart';
import '../widgets/drawer.dart';
import '../widgets/revenue_cat_widget.dart';
import '../widgets/show_confirmation_dialog.dart';
import '../widgets/snack_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ImageCubit _imageCubit;
  double _userCredits = 0.0;
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
  Future<String> _downloadImage(
      Uint8List imageBytes, String customPart_) async {
    try {
      DateTime now = DateTime.now();

      int year = now.year;
      int month = now.month;
      int day = now.day;
      int hour = now.hour;
      int minute = now.minute;
      int second = now.second;
      final time = '$year-$month-$day $hour:$minute:$second';
      final imageName = '$customPart_$time';

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
      print('Error saving image to gallery: $error');
      throw error; // Rethrow the error
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

    // Fetch and display user credits
    _fetchUserCredits();
  }

  String userUid = AuthentificationService().currentUser.uid;

  Future<void> _fetchUserCredits() async {
    try {
      DocumentSnapshot userSnapshot = await UserDatabaseHelper().getUserData(
          userUid); // Implement this method in your UserDatabaseHelper

      // Extract and update credits
      double credits = (userSnapshot.data()
              as Map<String, dynamic>?)?[UserDatabaseHelper.CREDITS] ??
          0;
      setState(() {
        _userCredits = credits;
      });
    } catch (e) {
      print('Error fetching user credits: $e');
    }
  }

  Future<double> getDebitValue() async {
    try {
      // Retrieve the document from Firestore
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('debit_collection')
          .doc('debit_doc')
          .get();

      // Check if the document exists and contains the 'credit' field
      if (documentSnapshot.exists && documentSnapshot.data() != null) {
        // Explicitly cast the data to Map<String, dynamic>
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;

        // Retrieve the credit value
        double debitValue = (data['debitValue'] ?? 0.0).toDouble();

        // Retrieve the credit value
        // double debitValue = (data['debitValue'] ?? 0.0).toDouble();
        // // Retrieve the credit value
        // double debitValue = documentSnapshot.data()!['debitValue'];

        return debitValue;
      } else {
        print('Document does not exist or credit field is missing.');
        return 0.0; // or handle the default value appropriately
      }
    } catch (e) {
      print('Error retrieving credit value: $e');
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
          return widget;
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

  Future fetchOffers(BuildContext context) async {
    final offerings = await PurchaseApi.fetchOffersByIds(Coins.allIds);

    if (offerings.isEmpty) {
      ShowSnackBar()
          .showSnackBar(context, AppLocalizations.of(context)!.noPlansFound);
    } else {
      packages = offerings
          .map((offer) => offer.availablePackages)
          .expand((pair) => pair)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? image;
    // Mapping of payment options
    List<Map<String, dynamic>> paymentOptions = [
      {
        'name': 'Card Payment',
        'image': 'assets/icons/stripe_method.svg',
        'onTap': () {
          fetchOffers(context);
          print(packages);
          showPaymentDialog(context, revenueCatWidget(packages));
        },
      },
      // {'name': 'Crypto Payment', 'image': 'assets/icons/0xprocessing_method.svg', 'onTap': {}},
      // {'name': 'Payeer', 'image': 'assets/icons/payeer_method.svg', 'onTap': {}},
      // {'name': 'Enot', 'image': 'assets/icons/enot_method.svg', 'onTap': {}},
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
    return UpgradeAlert(
      upgrader: Upgrader(
          durationUntilAlertAgain: const Duration(days: 1),
          dialogStyle: Platform.isIOS
              ? UpgradeDialogStyle.cupertino
              : UpgradeDialogStyle.material,
          canDismissDialog: true,
          shouldPopScope: () {
            return true;
          }),
      child: BlocProvider(
        create: (context) => _imageCubit,
        child: Scaffold(
          key: scaffoldKey,
          drawer: AppDrawer(appVersion: _appVersion),
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
                      return const CircularProgressIndicator();
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

                    // Assuming 'credits' is the field in your document that holds the user's credits.
                    double credits = userData['credits'] ?? 0.0;

                    return InkWell(
                      onTap: () {
                        showPaymentOptions(
                          context,
                          Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.75,
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.selectPayment,
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
                                      (BuildContext context, int index) {
                                    return InkWell(
                                      onTap: () {
                                        paymentOptions[index]['onTap']();
                                      },
                                      child: Card(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        margin: const EdgeInsets.all(16.0),
                                        child: Container(
                                          height:
                                              100, // Adjust the height as needed
                                          padding: const EdgeInsets.all(16.0),
                                          child: Center(
                                            child: SvgPicture.asset(
                                                paymentOptions[index]['image']),
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
                      },
                      child: Row(
                        children: [
                          // Replace the text with an icon (e.g., Icons.monetization_on)
                          const Icon(Icons.monetization_on, size: 40),
                          const SizedBox(
                              width:
                                  4), // Adjust the spacing between icon and credits
                          Text(
                            '$credits',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
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
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.enterPromptExample,
                        labelText: AppLocalizations.of(context)!.enterPrompt,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                      ),
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
                        padding: const EdgeInsets.all(10.0),
                        child: DefaultButton(
                          press: () async {
                            bool allowed =
                                AuthentificationService().currentUserVerified;
                            if (!allowed) {
                              final reverify = await showConfirmationDialog(
                                context,
                                "You haven't verified your email address. This action is only allowed for verified users.",
                                positiveResponse: "Resend verification email",
                                negativeResponse: "Go back",
                              );

                              if (reverify) {
                                try {
                                  bool verificationResult =
                                      await AuthentificationService()
                                          .sendVerificationEmailToCurrentUser();

                                  if (verificationResult) {
                                    ShowSnackBar().showSnackBar(
                                      context,
                                      "Verification email sent successfully",
                                    );
                                  } else {
                                    // Handle case where verification email sending failed
                                    ShowSnackBar().showSnackBar(
                                      context,
                                      "Failed to send verification email",
                                    );
                                  }
                                } catch (error) {
                                  // Handle other exceptions
                                  print(
                                      'Error during email verification: $error');
                                  ShowSnackBar().showSnackBar(
                                    context,
                                    "An error occurred during email verification",
                                  );
                                }
                              }
                              return;
                            }

                            if (_textEditingController.text.isEmpty) {
                              ShowSnackBar().showSnackBar(
                                context,
                                AppLocalizations.of(context)!.inputSomeText,
                              );
                            } else {
                              try {
                                Uint8List image = await _imageCubit.generate(
                                  _textEditingController.text,
                                  _selectedStyle,
                                  _selectedResolution,
                                );

                                // If image generation is successful, deduct credits
                                bool deductionResult;

                                // Check if the generated image is not empty
                                if (image.isNotEmpty) {
                                  double debitValue = await getDebitValue();
                                  print('Credit value retrieved: $debitValue');
                                  deductionResult = await UserDatabaseHelper()
                                      .deductCreditsForUser(
                                          userUid, debitValue);

                                  if (deductionResult) {
                                    // If credits deducted successfully, proceed with the image
                                    // display or any other actions you need to perform.
                                  } else {
                                    // Insufficient credits. Show a message.
                                    ShowSnackBar().showSnackBar(
                                      context,
                                      AppLocalizations.of(context)!
                                          .insufficientCredits,
                                    );
                                  }
                                } else {
                                  // Handle the case where the image is not generated successfully
                                  ShowSnackBar().showSnackBar(
                                    context,
                                    AppLocalizations.of(context)!
                                        .failedGeneration,
                                  );
                                }
                              } catch (error) {
                                // Handle the image generation error
                                print('Error during image generation: $error');
                                ShowSnackBar().showSnackBar(
                                  context,
                                  AppLocalizations.of(context)!
                                      .errorImageGeneration,
                                );
                              }
                            }
                          },
                          text: AppLocalizations.of(context)!.create,
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
                              // mainAxisAlignment: MainAxisAlignment.center,
                              // crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Lottie.asset(
                                  'assets/animations/infinite-loader.json',
                                  frameRate: FrameRate(20),
                                  alignment: Alignment.center,
                                  height: 300,
                                  repeat: true,
                                  animate: true,
                                ),
                                Text(
                                  AppLocalizations.of(context)!.creatingProcess,
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
                                        AppLocalizations.of(context)!.cancel))
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
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.height *
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
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.height *
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
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                child: Text(
                                  AppLocalizations.of(context)!.resultsNotFound,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
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
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
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
    );
  }
}
