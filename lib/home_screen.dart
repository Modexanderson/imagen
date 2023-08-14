import 'dart:io';

import 'package:brain_fusion/brain_fusion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:imagen/drawer.dart';
import 'package:imagen/snack_bar.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final AI _ai = AI();

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
  Uint8List? _generatedImageData;

  // /// The [_generate] function to generate image data.
  // Future<Uint8List> _generate(
  //     String query, AIStyle style, Resolution resolution) async {
  //   /// Call the runAI method with the required parameters.
  //   Uint8List image = await _ai.runAI(query, style, resolution);
  //   return image;
  // }

  // Future<void> _generateImage(
  //     String query, AIStyle style, Resolution resolution) async {
  //   try {
  //     setState(() {
  //       _generatedImageData = null; // Clear previous image data
  //     });

  //     Uint8List image = await _generate(query, style, resolution);
  //     setState(() {
  //       _generatedImageData = image; // Store the new generated image data
  //       _isLoading = false;
  //     });
  //   } catch (error) {
  //     setState(() {
  //       _generatedImageData = null; // Clear image data in case of error
  //       var _error = error.toString(); // Store the error message
  //     });
  //   }
  // }
  bool _isGenerating = false;

  Future<void> _generateImage(
      String query, AIStyle style, Resolution resolution) async {
    if (_isGenerating) {
      try {
        // Set the flag to true to indicate the function is running.
        _isGenerating = true;

        // Call the runAI method with the required parameters.
        Uint8List image = await _ai.runAI(query, style, resolution);

        // You can return, process, or store the image here.
        // ...
      } catch (e) {
        setState(() {
          _generatedImageData = null; // Clear image data in case of error
          var error = e.toString(); // Store the error message
        });
        // Handle any exceptions if needed.
      } finally {
        // Reset the flag to false when the function completes or exits.
        _isGenerating = false;
      }
    }
  }

  void stopGeneration() {
    _isGenerating = false;
  }

  @override
  void dispose() {
    /// Dispose the [_queryController].
    _textEditingController.dispose();
    super.dispose();
  }

  bool _isButtonClicked = false;
  bool _isLoading = false;

// Future<String?> _downloadImage(
  //     Uint8List imageBytes, String customPart) async {
  //   DateTime now = DateTime.now();

  //   int year = now.year;
  //   int month = now.month;
  //   int day = now.day;
  //   int hour = now.hour;
  //   int minute = now.minute;
  //   int second = now.second;
  //   final time = '$year-$month-$day $hour:$minute:$second';
  //   final imageName = '$customPart$time';

  //   Directory directory = await getTemporaryDirectory();
  //   File imageFile = File('${directory.path}/$imageName');

  //   await imageFile.writeAsBytes(imageBytes);

  //   // Copy the image to the gallery
  //   final result = await ImageGallerySaver.saveFile(imageFile.path,
  //       isReturnPathOfIOS: true);

  //   if (result['isSuccess']) {
  //     // Image saved successfully
  //     print('Image saved to gallery with custom name: $imageName');
  //     return imageFile.path; // Return the path
  //   } else {
  //     // Image save failed
  //     print('Failed to save image to gallery');
  //     return null;
  //   }
  // }

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

  @override
  Widget build(BuildContext context) {
    /// The size of the container for the generated image.
    final double size = Platform.isAndroid || Platform.isIOS
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height / 2;
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(
            context,
          )!
              .appTitle,
          style: const TextStyle(
              fontSize: 40, fontWeight: FontWeight.bold, fontFamily: 'Alva'),
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
                    hintText: AppLocalizations.of(context)!.enterPromptExample,
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
                    // IconButton(
                    //     icon: Column(
                    //       children: [
                    //         const Icon(
                    //           Icons.draw,
                    //         ),
                    //         const Text('Style'),
                    //         Text(formattedStyleText[_selectedStyle].toString())
                    //       ],
                    //     ),
                    //     onPressed: () {
                    //       _showStylesDialog();
                    //     })
                  ],
                ),
                _isLoading
                    ? const SizedBox()
                    : ElevatedButton(
                        onPressed: () {
                          if (_textEditingController.text.isEmpty) {
                            ShowSnackBar().showSnackBar(context,
                                AppLocalizations.of(context)!.inputSomeText);
                          } else {
                            setState(() {
                              _isButtonClicked = true;
                              _isLoading = true;
                            });
                            _generateImage(
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
                      ),
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
                    child: _isButtonClicked
                        ? _generatedImageData != null
                            ? Image.memory(_generatedImageData!)
                            // : LoadingDialogWidget(
                            //     generatedImageData:
                            //         _generatedImageData == null,
                            //   )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Lottie.asset(
                                        'assets/animations/infinite-loader.json',
                                        width:
                                            MediaQuery.of(context).size.width /
                                                4),
                                    const SizedBox(height: 0),
                                    Text(
                                      AppLocalizations.of(context)!
                                          .creatingProcess,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                          setState(() {
                                            stopGeneration();
                                            _isLoading = false;
                                            _isButtonClicked = false;

                                            ShowSnackBar().showSnackBar(
                                                context,
                                                AppLocalizations.of(context)!
                                                    .processCanceled);
                                          });
                                        },
                                        child: Text(
                                            AppLocalizations.of(context)!
                                                .cancel))
                                  ],
                                ),
                              )
                        : const SizedBox(),
                  ),
                ),
                _generatedImageData != null
                    ? ElevatedButton(
                        onPressed: () {
                          _downloadImage(
                            _generatedImageData!,
                            _textEditingController.text,
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Theme.of(context).colorScheme.secondary),
                          foregroundColor: MaterialStateProperty.all<Color>(
                            Colors
                                .white, // Use white text for better visibility
                          ),
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
                        child: Text(AppLocalizations.of(context)!.download),
                      )
                    : const SizedBox(),
              ]),
        ),
      ),
    );
  }
}
