import 'package:aura_bot_flutter/domain/entities/detected_object.dart';

class DetectedObjectModel extends DetectedObject {
  const DetectedObjectModel({
    required super.name,
    required super.confidence,
    required super.description,
    super.color,
  });

  factory DetectedObjectModel.fromMap(Map<String, dynamic> map) {
    return DetectedObjectModel(
      name: map['name'] ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      color: map['color'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'confidence': confidence,
      'description': description,
      if (color != null) 'color': color,
    };
  }
}
