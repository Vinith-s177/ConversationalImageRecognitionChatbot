class DetectedObject {
  final String name;
  final double confidence;
  final String description;
  final String? color;

  const DetectedObject({
    required this.name,
    required this.confidence,
    required this.description,
    this.color,
  });
}
