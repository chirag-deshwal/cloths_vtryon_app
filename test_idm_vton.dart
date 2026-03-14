import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

Future<void> main() async {
  // Use public un-authenticated yisol/IDM-VTON
  var urlStr = 'https://yisol-idm-vton.hf.space/call/tryon';
  final uri = Uri.parse(urlStr);
  
  // Minimal 1x1 base64 transparent PNGs for testing
  String base64Image = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=";
  
  final Map<String, dynamic> payload = {
    "data": [
      {
         "background": {
            "path": "data:image/png;base64,$base64Image",
            "meta": {"_type": "gradio.FileData"}
         },
         "layers": [],
         "composite": null
      },
      {
          "path": "data:image/png;base64,$base64Image",
          "meta": {"_type": "gradio.FileData"}
      },
      "a red t-shirt",
      true,
      true,
      30,
      42
    ]
  };

  print("Sending POST request to /call/tryon...");
  var response = await http.post(
    uri,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(payload),
  );

  if (response.statusCode != 200) {
    print("Failed to start event: \${response.statusCode} \${response.body}");
    return;
  }

  var decoded = jsonDecode(response.body);
  String eventId = decoded['event_id'];
  print("Got event_id: $eventId");

  // Now listen to SSE stream
  var eventUriStr = 'https://yisol-idm-vton.hf.space/call/tryon/$eventId';
  print("Listening to SSE stream: $eventUriStr");
  
  var request = http.Request('GET', Uri.parse(eventUriStr));
  var streamedResponse = await request.send();

  await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
    print("Received chunk: $chunk");
    if (chunk.contains('event: complete')) {
      print("Stream completed!");
      break;
    }
  }
}
