import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterClient {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  
  // Set your OpenRouter API key here or load via build configs
  static const String _openRouterApiKey = 'YOUR_OPENROUTER_API_KEY';

  final http.Client client;

  OpenRouterClient({http.Client? httpClient}) : client = httpClient ?? http.Client();

  Future<String> getCompletions({
    required String prompt,
    String? base64Image,
    String? mimeType,
    String model = 'google/gemini-2.5-flash:free',
  }) async {
    try {
      final List<Map<String, dynamic>> contentList = [
        {
          'type': 'text',
          'text': prompt,
        }
      ];

      if (base64Image != null && mimeType != null) {
        contentList.add({
          'type': 'image_url',
          'image_url': {
            'url': 'data:$mimeType;base64,$base64Image',
          }
        });
      }

      final Map<String, dynamic> requestPayload = {
        'model': model,
        'messages': [
          {
            'role': 'user',
            'content': contentList,
          }
        ]
      };

      final response = await client.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openRouterApiKey',
          'HTTP-Referer': 'https://conversational-chatbot-frontend.vercel.app', // Or dynamic based on environment
          'X-Title': 'Conversational Image Recognition Chatbot',
        },
        body: json.encode(requestPayload),
      );

      if (response.statusCode != 200) {
        String errorMsg = 'OpenRouter HTTP ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          if (errorBody['error'] != null) {
            errorMsg += ': ${errorBody['error']['message']}';
          }
        } catch (_) {}
        throw Exception(errorMsg);
      }

      final Map<String, dynamic> responseData = json.decode(response.body);
      final List? choices = responseData['choices'];
      if (choices != null && choices.isNotEmpty) {
        final Map? message = choices[0]['message'];
        if (message != null && message['content'] != null) {
          return message['content'].toString();
        }
      }
      throw Exception('Unexpected empty completion choice from OpenRouter.');
    } catch (e) {
      throw Exception('Failed to get response from AI model: $e');
    }
  }
}
