import 'package:aura_bot_flutter/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getMessages({required String userId});
  
  Future<ChatMessage> sendMessage({
    required String userId,
    required String userPrompt,
    String? base64Image,
    String? mimeType,
    required List<ChatMessage> history,
  });
  
  Future<void> clearHistory({required String userId});
}
