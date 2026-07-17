import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aura_bot_flutter/data/models/chat_message_model.dart';
import 'package:aura_bot_flutter/domain/entities/chat_message.dart';
import 'package:aura_bot_flutter/domain/repositories/chat_repository.dart';
import 'package:uuid/uuid.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Uuid _uuid = const Uuid();

  // Removing openrouter client from constructor
  ChatRepositoryImpl({Object? openRouterClient});

  String get _baseUrl {
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8081';
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  @override
  Future<List<ChatMessage>> getMessages({required String userId}) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/chat/history'),
        headers: {'Authorization': 'Bearer $token', 'Bypass-Tunnel-Reminder': 'true'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((msg) => ChatMessageModel(
          id: msg['id'].toString(),
          sender: msg['sender'],
          content: msg['content'],
          timestamp: DateTime.now(), // Real app should parse msg['timestamp']
          imageUrl: msg['imageUrl'],
        )).toList();
      } else {
        throw Exception('Failed to load chat history');
      }
    } catch (e) {
      throw Exception('Failed to get chat messages: $e');
    }
  }

  @override
  Future<ChatMessage> sendMessage({
    required String userId,
    required String userPrompt,
    String? base64Image,
    String? mimeType,
    required List<ChatMessage> history,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      String? imagePath;

      // 1. If image is present, upload it to the Spring Boot backend
      if (base64Image != null && mimeType != null) {
        final Uint8List imageBytes = base64Decode(base64Image);
        final String extension = mimeType.split('/').last;
        final String filename = '${_uuid.v4()}.$extension';
        
        var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/image/upload'));
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Bypass-Tunnel-Reminder'] = 'true';
        request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: filename));
        
        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          imagePath = data['imagePath'];
        } else {
          throw Exception('Failed to upload image');
        }
      }

      // 2. Send the message and imagePath to the chat endpoint
      final chatResponse = await http.post(
        Uri.parse('$_baseUrl/api/chat/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Bypass-Tunnel-Reminder': 'true'
        },
        body: jsonEncode({
          'message': userPrompt,
          'imagePath': imagePath ?? '',
        }),
      );

      if (chatResponse.statusCode == 200) {
        final data = jsonDecode(chatResponse.body);
        if (data['success'] == true && data['reply'] != null) {
          final reply = data['reply'];
          return ChatMessageModel(
            id: reply['id']?.toString() ?? _uuid.v4(),
            sender: reply['sender'] ?? 'bot',
            content: reply['content'] ?? '',
            timestamp: DateTime.now(),
          );
        } else {
          throw Exception('Failed to get reply: ${data['error']}');
        }
      } else {
        throw Exception('Failed to send message: ${chatResponse.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  @override
  Future<void> clearHistory({required String userId}) async {
    final token = await _getToken();
    if (token == null) throw Exception('Not authenticated');

    try {
      await http.post(
        Uri.parse('$_baseUrl/api/chat/clear'),
        headers: {'Authorization': 'Bearer $token', 'Bypass-Tunnel-Reminder': 'true'},
      );
    } catch (e) {
      throw Exception('Failed to clear chat history: $e');
    }
  }
}
