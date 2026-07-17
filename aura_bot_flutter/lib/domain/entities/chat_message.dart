import 'package:aura_bot_flutter/domain/entities/detected_object.dart';

class ChatMessage {
  final String id;
  final String sender; // 'user' or 'bot'
  final String content;
  final DateTime timestamp;
  final String? imageUrl;
  final String? ocrText;
  final List<DetectedObject>? detectedObjects;

  const ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.imageUrl,
    this.ocrText,
    this.detectedObjects,
  });
}
