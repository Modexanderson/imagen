// ignore_for_file: use_build_context_synchronously

import 'dart:io' show Platform;

import 'package:brain_fusion/brain_fusion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:upgrader/upgrader.dart';
import '../bloc/image_cubit.dart';

import '../widgets/drawer.dart';
import '../widgets/snack_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ImageCubit _imageCubit;
  String _appVersion = '';
  final TextEditingController _textEditingController = TextEditingController();
  var scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<AIStyle, String> formattedStyleText = {
    AIStyle.noStyle: 'no style',
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

  Future<void> _downloadImage(
    Uint8List imageBytes,
    String customPart_,
  ) async {
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
          .showSnackBar(context, 'Image successfully saved to gallery');
      // Image saved successfully
      if (kDebugMode) {
        print('Image successfully saved to gallery');
      }
    } else {
      ShowSnackBar().showSnackBar(context, 'Failed to save image to gallery');
      // Image save failed
      if (kDebugMode) {
        print('Failed to save image to gallery');
      }
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
  }

  @override
  void dispose() {
    _imageCubit.close();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? image;

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
            title: Text(
              AppLocalizations.of(
                context,
              )!
                  .appTitle,
              style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Alva'),
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
                  TextFormField(
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
                      return ElevatedButton(
                        onPressed: () {
                          if (_textEditingController.text.isEmpty) {
                            ShowSnackBar().showSnackBar(context,
                                AppLocalizations.of(context)!.inputSomeText);
                          } else {
                            _imageCubit.generate(
                              _textEditingController.text,
                              _selectedStyle,
                              _selectedResolution,
                            );
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).colorScheme.secondary),
                          elevation: MaterialStateProperty.all(10),
                          fixedSize: MaterialStateProperty.all(
                              const Size.fromWidth(double.maxFinite)),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                            const EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 20.0),
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!.create),
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
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: SizedBox(
                            height: 60,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: ElevatedButton(
                              onPressed: () {
                                _downloadImage(
                                  image!,
                                  _textEditingController.text,
                                );
                              },
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<
                                        Color>(
                                    Theme.of(context).colorScheme.secondary),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Colors
                                      .white, // Use white text for better visibility
                                ),
                                elevation: MaterialStateProperty.all(10),
                                fixedSize: MaterialStateProperty.all(
                                    const Size.fromWidth(double.maxFinite)),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                padding: MaterialStateProperty.all<
                                    EdgeInsetsGeometry>(
                                  const EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 20.0),
                                ),
                              ),
                              child:
                                  Text(AppLocalizations.of(context)!.download),
                            )),
                      );
                    }
                    return const SizedBox();
                  })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
