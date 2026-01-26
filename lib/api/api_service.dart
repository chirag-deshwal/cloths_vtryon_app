import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../utils/constants.dart';

class ApiService {
  Future<Uint8List?> generateTryOn(
    XFile personImage,
    XFile clothImage,
    String category,
  ) async {
    try {
      // 1. Convert images to Base64
      String personBase64 = await _imageToBase64(personImage);
      String clothBase64 = await _imageToBase64(clothImage);

      // 2. Prepare Payload
      // This payload structure is common for Gradio/Spaces APIs.
      // If using the official Inference API for a specific model, checking the "API" button on the HF model page is best.
      // We will assume a structure commonly used for Virtual Try-On demos.
      // Adjust the keys ('human_image', 'garm_img', etc.) based on the specific model's requirements.

      final Map<String, dynamic> payload = {
        "inputs": {
          "image": personBase64, // or "human_img"
          "garm_img": clothBase64,
          "category": category, // upper_body, lower_body, dresses
          "garment_des": "cloth", // specific description often required
        },
      };

      // Alternative: If hitting a Gradio API directly:
      // final payload = {
      //   "data": [
      //     "data:image/jpeg;base64,$personBase64",
      //     "data:image/jpeg;base64,$clothBase64",
      //     "cloth",
      //     true,
      //     true,
      //     30,
      //     42
      //   ]
      // };

      var uri = Uri.parse(AppConstants.modelApiUrl);
      var response = await http.post(
        uri,
        headers: {
          "Authorization": "Bearer ${AppConstants.hfApiToken}",
          "Content-Type": "application/json",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        // 3. Handle Response
        // Some APIs return the image bytes directly.
        // Others return JSON with a generated image string.

        if (response.headers['content-type']?.contains('image') ?? false) {
          return response.bodyBytes;
        } else {
          // Assume JSON with base64 or URL
          var decoded = jsonDecode(response.body);
          if (decoded is List && decoded.isNotEmpty) {
            // Handle generic list output
            // return _parseOutput(decoded[0]);
            // Simplest fallback for now:
            return response.bodyBytes;
          } else if (decoded is Map) {
            // Check for specific keys like 'generated_image'
            if (decoded.containsKey('generated_image')) {
              // decode base64
              // return base64Decode(decoded['generated_image']);
            }
          }
        }
        return response.bodyBytes; // Fallback
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }

  Future<String> _imageToBase64(XFile file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }
}
