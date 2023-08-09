import 'dart:io';

import 'package:brain_fusion/brain_fusion.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:imagen/constants.dart';
import 'package:imagen/drawer.dart';
import 'package:imagen/snack_bar.dart';
import 'package:lottie/lottie.dart';

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

  /// The [_generate] function to generate image data.
  Future<Uint8List> _generate(
      String query, AIStyle style, Resolution resolution) async {
    /// Call the runAI method with the required parameters.
    Uint8List image = await _ai.runAI(query, style, resolution);
    return image;
  }

  Future<void> _generateImage(
      String query, AIStyle style, Resolution resolution) async {
    try {
      setState(() {
        _generatedImageData = null; // Clear previous image data
      });

      Uint8List image = await _generate(query, style, resolution);
      setState(() {
        _generatedImageData = image; // Store the new generated image data
      });
    } catch (error) {
      setState(() {
        _generatedImageData = null; // Clear image data in case of error
        var _error = error.toString(); // Store the error message
      });
    }
  }

  @override
  void dispose() {
    /// Dispose the [_queryController].
    _textEditingController.dispose();
    super.dispose();
  }

  bool _isButtonClicked = false;

  Future<void> _downloadImage(Uint8List imageBytes) async {
    final result = await ImageGallerySaver.saveImage(imageBytes);

    if (result['isSuccess']) {
      // Image saved successfully
      print('Image saved to gallery');
    } else {
      // Image save failed
      print('Failed to save image to gallery');
    }
  }

  void _showStylesDialog() {
    showDialog<AIStyle>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Pick a Style'),
          children: [
            Container(
              padding: EdgeInsets.zero,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                children: formattedStyleText.entries.map((entry) {
                  return TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedStyle = entry.key;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(entry.value),
                  );
                }).toList(),
              ),
            )
          ],
        );
      },
    );
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
        title: const Text(
          'Imagen',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
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
                  decoration: const InputDecoration(
                    hintText:
                        "Enter prompt, e.g: cyberpunk anatomical heart model",
                    labelText: "Enter prompt",
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                  ),
                  validator: (value) {
                    if (_textEditingController.text.isEmpty) {
                      return 'Input Some Texts...';
                    }
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,

                  //  TextField(
                  //   controller: _textEditingController,
                  //   decoration: const InputDecoration(
                  //     hintText: 'Enter query text...',
                  //   ),
                  // ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
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
                ElevatedButton(
                  onPressed: () {
                    if (_textEditingController.text.isEmpty) {
                      ShowSnackBar()
                          .showSnackBar(context, "Input Some Texts...");
                    } else {
                      setState(() {
                        _isButtonClicked = true;
                      });
                      _generateImage(
                        _textEditingController.text,
                        _selectedStyle,
                        _selectedResolution,
                      );
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(kPrimaryColor),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white, // Use white text for better visibility
                    ),
                    elevation: MaterialStateProperty.all(10),
                    fixedSize: MaterialStateProperty.all(
                        const Size.fromWidth(double.maxFinite)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                      const EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 20.0),
                    ),
                  ),
                  child: const Text('Create'),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue, // Set the border color
                          width: 2.0, // Set the border width
                        ),
                      ),
                      height: size,
                      width: size,
                      child: _isButtonClicked
                          ? _generatedImageData != null
                              ? Column(
                                  children: [
                                    Image.memory(_generatedImageData!),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        _downloadImage(_generatedImageData!);
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                kPrimaryColor),
                                        foregroundColor:
                                            MaterialStateProperty.all<Color>(
                                          Colors
                                              .white, // Use white text for better visibility
                                        ),
                                        elevation:
                                            MaterialStateProperty.all(10),
                                        fixedSize: MaterialStateProperty.all(
                                            const Size.fromWidth(
                                                double.maxFinite)),
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        padding: MaterialStateProperty.all<
                                            EdgeInsetsGeometry>(
                                          const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 20.0),
                                        ),
                                      ),
                                      child: const Text('Download'),
                                    ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Lottie.asset(
                                          'assets/animations/infinite-loader.json',
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              4),
                                      const SizedBox(height: 0),
                                      const Text(
                                        'Loading...',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                          : const SizedBox()),
                )
              ]),
        ),
      ),
    );
  }

  // Widget _showGeneratedImage() {
  //   return Container(
  //     child: FutureBuilder<Uint8List>(
  //       /// Call the [_generate] function to get the image data.
  //       future: _generate(
  //           _textEditingController.text, _selectedStyle, Resolution.r1x1),
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           /// While waiting for the image data, display a loading indicator.
  //           return const CircularProgressIndicator();
  //         } else if (snapshot.hasError) {
  //           if (kDebugMode) {
  //             print(snapshot.error);
  //           }

  //           /// If an error occurred while getting the image data, display an error message.
  //           return Text('Error: ${snapshot.error}');
  //         } else if (snapshot.hasData) {
  //           /// If the image data is available, display the image using Image.memory().
  //           return Image.memory(snapshot.data!);
  //         } else {
  //           /// If no data is available, display a placeholder or an empty container.
  //           return Container();
  //         }
  //       },
  //     ),
  //   );
  // }
}
