import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../api/enums.dart';
import '../api/fusion_brain_api.dart';
import '../models/.env.dart';

enum ImageGenerationStatus {
  initial,
  loading,
  loaded,
  error,
  stopped,
}

class ImageProvider extends ChangeNotifier {
  ImageGenerationStatus _status = ImageGenerationStatus.initial;
  Uint8List? _generatedImage;
  String _errorMessage = '';
  bool _isGenerating = false;

  final FusionBrainAPI _fusionBrainApi = FusionBrainAPI(
    'https://api-key.fusionbrain.ai',
    apiKey,
    secretKey,
  );

  // Getters
  ImageGenerationStatus get status => _status;
  Uint8List? get generatedImage => _generatedImage;
  String get errorMessage => _errorMessage;
  bool get isGenerating => _isGenerating;

  Future<Uint8List> generateImage(
    String query,
    AIStyle style,
    Resolution resolution,
  ) async {
    _setStatus(ImageGenerationStatus.loading);
    _isGenerating = true;
    _errorMessage = '';

    try {
      if (kDebugMode) {
        print('Starting image generation...');
        print('Query: $query');
        print('Style: $style');
        print('Resolution: $resolution');
      }

      String imageString = await _fusionBrainApi.generateImage(
        query,
        style,
        resolution,
      );

      if (!_isGenerating) {
        _setStatus(ImageGenerationStatus.stopped);
        return Uint8List(0);
      }

      // Decode base64 string to Uint8List
      Uint8List image = base64.decode(imageString);
      _generatedImage = image;

      if (kDebugMode) {
        print('Image generation completed successfully');
      }

      _setStatus(ImageGenerationStatus.loaded);
      return image;
    } catch (error) {
      if (kDebugMode) {
        print('Error during image generation: $error');
      }

      _errorMessage = error.toString();
      _setStatus(ImageGenerationStatus.error);
      return Uint8List(0);
    } finally {
      _isGenerating = false;
    }
  }

  void setSelectedImage(Uint8List image) {
    _generatedImage = image;
    _setStatus(ImageGenerationStatus.loaded);
  }

  void cancelGeneration() {
    if (_isGenerating) {
      _isGenerating = false;
      _setStatus(ImageGenerationStatus.stopped);
      if (kDebugMode) {
        print('Image generation cancelled');
      }
    }
  }

  void reset() {
    _generatedImage = null;
    _errorMessage = '';
    _isGenerating = false;
    _setStatus(ImageGenerationStatus.initial);
  }

  void _setStatus(ImageGenerationStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  @override
  void dispose() {
    _isGenerating = false;
    super.dispose();
  }
}
