import 'dart:convert';
import 'package:http/http.dart' as http;

const String url = 'https://yisol-idm-vton.hf.space/api/predict';

void main() async {
  print('Testing Space API connection to: $url');

  try {
    // Gradio Predict often accepts GET for info or POST for data
    // We send a bad payload just to check if the endpoint exists (should get 500 or 422, not 404 or 410)
    var response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "data": ["foo"],
      }),
    );

    print('Status Code: ${response.statusCode}');
    print('Body: ${response.body}');

    // Also try the new Gradio call endpoint
    var url2 = 'https://yisol-idm-vton.hf.space/call/tryon';
    print('\nTesting Space Call API: $url2');
    var response2 = await http.post(
      Uri.parse(url2),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"data": []}),
    );
    print('Status Code 2: ${response2.statusCode}');
    print('Body 2: ${response2.body}');
  } catch (e) {
    print('Error: $e');
  }
}
