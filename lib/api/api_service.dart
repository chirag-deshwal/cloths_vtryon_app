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

      // 2. Prepare Payload for Gradio Space
      // The yisol/IDM-VTON space expects a list of arguments in "data".
      // Based on the space's API definition:
      // fn_index is sometimes needed, or just /api/predict with "data"

      final Map<String, dynamic> payload = {
        "data": [
          "data:image/jpeg;base64,$personBase64", // Person image
          "data:image/jpeg;base64,$clothBase64", // Garment image
          category, // Description/Category (e.g. "upper_body" or simple text)
          true, // is_checked (crop?)
          true, // is_checked (denoise?)
          30, // steps
          42, // seed
        ],
      };

      var uri = Uri.parse(AppConstants.modelApiUrl);

      var response = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          // "Authorization": "Bearer ${AppConstants.hfApiToken}", // Space might not need token if public
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        // 3. Handle Response from Gradio
        // { "data": [ "data:image/webp;base64,....", ... ] }

        var decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('data')) {
          var dataList = decoded['data'] as List;
          if (dataList.isNotEmpty && dataList[0] is String) {
            String resultInfo = dataList[0];
            // It might be a file path (if fn returning file) or base64
            // Gradio usually returns "data:image/..." for images in API
            if (resultInfo.startsWith('data:image')) {
              var parts = resultInfo.split(',');
              if (parts.length > 1) {
                return base64Decode(parts[1]);
              }
            }
            // Sometimes it returns a filepath like /tmp/... if not fetching base64
            // But usually payload with bas64 input returns base64 output
          }
        }

        // Fallback or debug
        print("Unexpected Response format: $decoded");
        return null;
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        return null;
      }
    } on http.ClientException catch (e) {
      print("ClientException (CORS or Network): $e");
      print(
        "Tip: If on Web, this is often due to CORS blocking 503/500 errors from the server.",
      );
      return null;
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
