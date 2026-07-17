import 'package:aura_bot_flutter/data/models/detected_object_model.dart';
import 'package:aura_bot_flutter/domain/entities/chat_message.dart';

class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.sender,
    required super.content,
    required super.timestamp,
    super.imageUrl,
    super.ocrText,
    super.detectedObjects,
  });

  factory ChatMessageModel.fromMap(Map<String, dynamic> map, String id) {
    final List? rawObjects = map['detectedObjects'];
    final List<DetectedObjectModel>? objects = rawObjects != null
        ? rawObjects.map((e) => DetectedObjectModel.fromMap(Map<String, dynamic>.from(e))).toList()
        : null;

    return ChatMessageModel(
      id: id,
      sender: map['sender'] ?? 'bot',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
      imageUrl: map['imageUrl'],
      ocrText: map['ocrText'],
      detectedObjects: objects,
    );
  }

  Map<String, dynamic> toMap() {
    final List<Map<String, dynamic>>? objectsMap = detectedObjects != null
        ? detectedObjects!.map((e) {
            if (e is DetectedObjectModel) {
              return e.toMap();
            } else {
              return DetectedObjectModel(
                name: e.name,
                confidence: e.confidence,
                description: e.description,
                color: e.color,
              ).toMap();
            }
          }).toList()
        : null;

    return {
      'sender': sender,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (ocrText != null) 'ocrText': ocrText,
      if (objectsMap != null) 'detectedObjects': objectsMap,
    };
  }
}
