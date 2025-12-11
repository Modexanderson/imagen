import 'dart:convert';
import 'package:flutter/foundation.dart';
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

  // Updated method to get pipeline ID (replaces getModelId)
  Future<String> getPipelineId() async {
    try {
      // Use the correct endpoint from the documentation
      final response = await http
          .get(
            Uri.parse('$baseUrl/key/api/v1/pipelines'),
            headers: _getAuthHeaders(),
          )
          .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Pipelines API Response Status: ${response.statusCode}');
        print('Pipelines API Response Body: ${response.body}');
        print('Request URL: $baseUrl/key/api/v1/pipelines');
        print('Request Headers: ${_getAuthHeaders()}');
      }

      if (response.statusCode == 404) {
        throw Exception(
            'Pipelines endpoint not found. API may have changed or keys may be invalid.');
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication failed. Please check your API keys.');
      }

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to get pipelines. Status: ${response.statusCode}, Body: ${response.body}');
      }

      if (response.body.isEmpty) {
        throw Exception('Empty response from pipelines API');
      }

      final data = json.decode(response.body);

      if (data == null || data is! List || data.isEmpty) {
        throw Exception('Invalid pipelines data structure: $data');
      }

      // Return the first pipeline's ID
      return data[0]['id'].toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting pipeline ID: $e');
      }
      rethrow;
    }
  }

  Future<String> generateImage(
      String query, AIStyle? style, Resolution? resolution) async {
    try {
      if (kDebugMode) {
        print('Starting image generation with query: $query');
        print('Base URL: $baseUrl');
        print('API Key length: ${apiKey.length}');
        print('Secret Key length: ${secretKey.length}');
      }

      final resolutionValues = getResolution(resolution);
      final styleValue = getStyle(style);

      // Get pipeline ID first
      String pipelineId;
      try {
        pipelineId = await getPipelineId();
        if (kDebugMode) {
          print('Using pipeline ID: $pipelineId');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Failed to get pipeline ID: $e');
        }
        rethrow;
      }

      // Create parameters according to the new API documentation
      final params = {
        "type": "GENERATE",
        "numImages": 1,
        "width": int.parse(resolutionValues.$1),
        "height": int.parse(resolutionValues.$2),
        "style": styleValue,
        "generateParams": {"query": query}
      };

      if (kDebugMode) {
        print('Generation params: ${jsonEncode(params)}');
      }

      // Create multipart request using the correct endpoint
      final formData = http.MultipartRequest(
          'POST', Uri.parse('$baseUrl/key/api/v1/pipeline/run'));

      // Set headers
      formData.headers.addAll(_getAuthHeaders());

      // Add pipeline_id as a field
      formData.fields['pipeline_id'] = pipelineId;

      // Add params as a file with proper content type
      formData.files.add(http.MultipartFile.fromString(
        'params',
        jsonEncode(params),
        contentType: MediaType('application', 'json'),
      ));

      if (kDebugMode) {
        print('Sending generation request to: ${formData.url}');
        print('Headers: ${formData.headers}');
        print('Fields: ${formData.fields}');
      }

      // Send the request with timeout
      final response =
          await formData.send().timeout(const Duration(seconds: 60));

      // Read the response
      final result = await http.Response.fromStream(response);

      if (kDebugMode) {
        print('Generation Response Status: ${response.statusCode}');
        print('Generation Response Body: ${result.body}');
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw Exception('Authentication failed. Please check your API keys.');
      }

      if (response.statusCode == 404) {
        throw Exception('API endpoint not found. The API may have changed.');
      }

      if (response.statusCode == 400) {
        throw Exception('Bad request. Check your parameters: ${result.body}');
      }

      if (response.statusCode == 415) {
        throw Exception('Unsupported media type. Check request format.');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (result.body.isEmpty) {
          throw Exception('Empty response from generation API');
        }

        final responseData = json.decode(result.body);
        if (responseData == null || responseData['uuid'] == null) {
          throw Exception(
              'Invalid response structure: missing uuid. Response: ${result.body}');
        }

        final generatedImages =
            await checkGenerationStatus(responseData['uuid']);

        if (generatedImages.isEmpty) {
          throw Exception('No images generated');
        }

        return generatedImages.first;
      } else {
        throw Exception(
            'Image generation failed. Status code: ${response.statusCode}. Response: ${result.body}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during image generation: $e');
      }
      rethrow;
    }
  }

  Future<List<String>> checkGenerationStatus(String requestId,
      {int attempts = 15, int delay = 10000}) async {
    if (kDebugMode) {
      print('Checking generation status for request: $requestId');
    }

    while (attempts > 0) {
      try {
        // Use the correct endpoint from the documentation
        final response = await http
            .get(
              Uri.parse('$baseUrl/key/api/v1/pipeline/status/$requestId'),
              headers: _getAuthHeaders(),
            )
            .timeout(const Duration(seconds: 30));

        if (kDebugMode) {
          print(
              'Status check response: ${response.statusCode} - ${response.body}');
        }

        if (response.statusCode != 200) {
          if (kDebugMode) {
            print('Status check failed with status: ${response.statusCode}');
          }
          attempts--;
          await Future.delayed(Duration(milliseconds: delay));
          continue;
        }

        if (response.body.isEmpty) {
          if (kDebugMode) {
            print('Empty response from status API');
          }
          attempts--;
          await Future.delayed(Duration(milliseconds: delay));
          continue;
        }

        final data = json.decode(response.body);

        if (data == null) {
          if (kDebugMode) {
            print('Null data from status API');
          }
          attempts--;
          await Future.delayed(Duration(milliseconds: delay));
          continue;
        }

        if (kDebugMode) {
          print('Current status: ${data['status']}');
        }

        if (data['status'] == 'DONE') {
          final result = data['result'];
          if (result == null ||
              result['files'] == null ||
              result['files'] is! List) {
            throw Exception('Invalid images data structure');
          }
          return List<String>.from(result['files']);
        } else if (data['status'] == 'FAIL') {
          final errorDescription = data['errorDescription'] ?? 'Unknown error';
          throw Exception(
              'Image generation failed on server: $errorDescription');
        }

        attempts--;
        await Future.delayed(Duration(milliseconds: delay));
      } catch (e) {
        if (kDebugMode) {
          print('Error checking status: $e');
        }
        attempts--;
        if (attempts <= 0) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: delay));
      }
    }

    throw Exception(
        'Generation timeout: status not DONE within specified attempts');
  }

  Map<String, String> _getAuthHeaders() {
    return {
      'X-Key': 'Key $apiKey',
      'X-Secret': 'Secret $secretKey',
    };
  }
}
