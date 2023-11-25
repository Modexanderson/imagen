import 'dart:convert';
import 'dart:typed_data';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;

import 'enums.dart';

class FusionBrainAPI {
  final String baseUrl;
  final String apiKey;
  final String secretKey;

  FusionBrainAPI(this.baseUrl, this.apiKey, this.secretKey);

  String getStyle(AIStyle? aiStyle) {
    switch (aiStyle) {
      case AIStyle.noStyle:
        return 'DEFAULT';
      case AIStyle.anime:
        return 'ANIME';
      case AIStyle.moreDetails:
        return 'UHD';
      case AIStyle.cyberPunk:
        return 'CYBERPUNK';
      case AIStyle.kandinskyPainter:
        return 'KANDINSKY';
      case AIStyle.aivazovskyPainter:
        return 'AIVAZOVSKY';
      case AIStyle.malevichPainter:
        return 'MALEVICH';
      case AIStyle.picassoPainter:
        return 'PICASSO';
      case AIStyle.goncharovaPainter:
        return 'GONCHAROVA';
      case AIStyle.classicism:
        return 'CLASSICISM';
      case AIStyle.renaissance:
        return 'RENAISSANCE';
      case AIStyle.oilPainting:
        return 'OILPAINTING';
      case AIStyle.pencilDrawing:
        return 'PENCILDRAWING';
      case AIStyle.digitalPainting:
        return 'DIGITALPAINTING';
      case AIStyle.medievalStyle:
        return 'MEDIEVALPAINTING';
      case AIStyle.render3D:
        return 'RENDER';
      case AIStyle.cartoon:
        return 'CARTOON';
      case AIStyle.studioPhoto:
        return 'STUDIOPHOTO';
      case AIStyle.portraitPhoto:
        return 'PORTRAITPHOTO';
      case AIStyle.khokhlomaPainter:
        return 'KHOKHLOMA';
      case AIStyle.christmas:
        return 'CRISTMAS';
      default:
        return 'DEFAULT';
    }
  }

  ///Create [getResolution] function to pass the [Resolution]
  (String, String) getResolution(Resolution? resolution) {
    switch (resolution) {
      case Resolution.r1x1:
        return ('1024', '1024');
      case Resolution.r2x3:
        return ('680', '1024');
      case Resolution.r3x2:
        return ('1024', '680');
      case Resolution.r9x16:
        return ('576', '1024');
      case Resolution.r16x9:
        return ('1024', '576');
      default:
        return ('1024', '1024');
    }
  }

  Future<String> getModelId() async {
    final response = await http.get(Uri.parse('$baseUrl/key/api/v1/models'),
        headers: _getHeaders());
    final data = json.decode(response.body);
    return data[0]['id'].toString();
  }
  

  Future<String> generateImage(
    String query, AIStyle? style, Resolution? resolution) async {
  try {
    final resolutionValues = getResolution(resolution);
    final styleValue = getStyle(style);

    final params = {
      "type": "GENERATE",
      "style": styleValue,
      // "numImages": "1",
      "width": resolutionValues.$1,
      "height": resolutionValues.$2,
      "generateParams": {"query": query, }
    };

    // Get the model_id
    final modelId = await getModelId();

    // Create a new FormData object
    final formData = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/key/api/v1/text2image/run'));

    // Set headers
    formData.headers.addAll(_getHeaders());

    // Add the 'params' field
    formData.files.add(http.MultipartFile.fromString(
      'params',
      jsonEncode(params),
      contentType: MediaType('application', 'json'),
    ));

    // Add the 'model_id' field
    formData.fields['model_id'] = modelId;

    // Send the request
    final response = await formData.send();

    // Read the response
    final result = await http.Response.fromStream(response);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final generatedImage =
          await checkGenerationStatus(json.decode(result.body)['uuid']);
      return generatedImage.firstOrNull!;
    } else {
      // Include the status code and response body in the error message
      throw Exception(
          'Image generation failed. Status code: ${response.statusCode}. Response: ${result.body}');
    }
  } catch (e) {
    // Handle other errors and return a default value or rethrow the exception
    print('Error during image generation: $e');
    rethrow;
  }
}


  Future<List<String>> checkGenerationStatus(String requestId,
      {int attempts = 10, int delay = 200}) async {
    while (attempts > 0) {
      final response = await http.get(
          Uri.parse('$baseUrl/key/api/v1/text2image/status/$requestId'),
          headers: _getHeaders());
      final data = json.decode(response.body);

      if (data['status'] == 'DONE') {
        return List<String>.from(data['images']);
      }

      attempts--;
      await Future.delayed(Duration(milliseconds: delay));
    }

    // Handle if status is not 'DONE' within the specified attempts
    return [];
  }

  Map<String, String> _getHeaders() {
    return {
      'X-Key': 'Key $apiKey',
      'X-Secret': 'Secret $secretKey',
      'Content-Type': 'application/json', // Add this line
    };
  }
}
