class DetectionHistory {
  final String gesture;
  final double confidence;
  final DateTime timestamp;

  DetectionHistory({
    required this.gesture,
    required this.confidence,
    required this.timestamp,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'gesture': gesture,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create from JSON
  factory DetectionHistory.fromJson(Map<String, dynamic> json) {
    return DetectionHistory(
      gesture: json['gesture'] as String,
      confidence: json['confidence'] as double,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
