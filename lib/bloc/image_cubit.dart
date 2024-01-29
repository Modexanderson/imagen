import 'dart:convert';
import 'dart:typed_data';

// import 'package:brain_fusion/brain_fusion.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../api/enums.dart';
import '../api/fusion_brain_api.dart';
import '../models/.env.dart';

part 'image_state.dart';


class ImageCubit extends Cubit<ImageState> {
  ImageCubit() : super(ImageInitial());
  bool _isGenerating = false;
  final FusionBrainAPI fusion_brain_api = FusionBrainAPI('https://api-key.fusionbrain.ai', apiKey, secretKey);

  Future<Uint8List> generate(String query, AIStyle style, Resolution resolution) async {
    emit(ImageLoading());
    _isGenerating = true; // Set the flag when generation starts
    try {
      String imageString = await fusion_brain_api.generateImage(query, style, resolution);
      Uint8List image = base64.decode(imageString); // Decode base64 string to Uint8List
      if (_isGenerating) {
        emit(ImageLoaded(image: image));
        return image; // Return the generated image
      } else {
        emit(ImageStopped()); // Emit a stopped state if generation is canceled
        return Uint8List(0); // Return an empty Uint8List or handle it as appropriate
      }
    } catch (error) {
      emit(ImageError(error: error.toString()));
      return Uint8List(0); // Return an empty Uint8List or handle it as appropriate
    } finally {
      _isGenerating = false; // Reset the flag when generation is complete
    }
  }

  void cancelGeneration() {
    if (_isGenerating) {
      _isGenerating = false; // Stop the generation process if it's running
      emit(ImageStopped()); // Emit a stopped state when canceled
    }
  }
}
