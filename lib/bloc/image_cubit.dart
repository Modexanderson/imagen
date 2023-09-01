import 'dart:typed_data';

import 'package:brain_fusion/brain_fusion.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'image_state.dart';

class ImageCubit extends Cubit<ImageState> {
  ImageCubit() : super(ImageInitial());
  final AI _ai = AI();
  bool _isGenerating = false;

  Future<void> generate(
      String query, AIStyle style, Resolution resolution) async {
    emit(ImageLoading());
    _isGenerating = true; // Set the flag when generation starts
    try {
      Uint8List image = await _ai.runAI(query, style, resolution);
      if (_isGenerating) {
        emit(ImageLoaded(image: image));
      } else {
        emit(ImageStopped()); // Emit a stopped state if generation is canceled
      }
    } catch (_) {
      emit(const ImageError(error: 'There is error . Try Again Later'));
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
