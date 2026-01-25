class ScanRecord {
  final String id;
  final String fileName;
  final DateTime timestamp;
  final bool isDeepfake;
  final double confidence;
  final String? resultNote;
  final String type; // 'upload' or 'monitor'

  ScanRecord({
    required this.id,
    required this.fileName,
    required this.timestamp,
    required this.isDeepfake,
    required this.confidence,
    this.resultNote,
    this.type = 'upload',
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'timestamp': timestamp.toIso8601String(),
      'isDeepfake': isDeepfake,
      'confidence': confidence,
      'resultNote': resultNote,
      'type': type,
    };
  }

  factory ScanRecord.fromJson(Map<String, dynamic> json) {
    return ScanRecord(
      id: json['id'],
      fileName: json['fileName'],
      timestamp: DateTime.parse(json['timestamp']),
      isDeepfake: json['isDeepfake'],
      confidence: json['confidence'],
      resultNote: json['resultNote'],
      type: json['type'] ?? 'upload',
    );
  }
}
