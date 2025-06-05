class VehicleDocument {
  final int? id;
  final int vehicleId;
  final String title;
  final String type; // 'registration', 'insurance', 'service_record', 'receipt', 'damage_report'
  final String filePath;
  final DateTime date;
  final String? description;
  final double? amount; // For receipts
  final Map<String, dynamic>? metadata;

  VehicleDocument({
    this.id,
    required this.vehicleId,
    required this.title,
    required this.type,
    required this.filePath,
    required this.date,
    this.description,
    this.amount,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'title': title,
      'type': type,
      'file_path': filePath,
      'date': date.toIso8601String(),
      'description': description,
      'amount': amount,
      'metadata': metadata != null ? _encodeMetadata(metadata!) : null,
    };
  }

  factory VehicleDocument.fromMap(Map<String, dynamic> map) {
    return VehicleDocument(
      id: map['id'],
      vehicleId: map['vehicle_id'],
      title: map['title'],
      type: map['type'],
      filePath: map['file_path'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      amount: map['amount'] != null ? (map['amount'] as num).toDouble() : null,
      metadata: map['metadata'] != null ? _decodeMetadata(map['metadata']) : null,
    );
  }

  static String _encodeMetadata(Map<String, dynamic> metadata) {
    return Uri.encodeFull(metadata.toString());
  }

  static Map<String, dynamic> _decodeMetadata(String encodedMetadata) {
    final decodedString = Uri.decodeFull(encodedMetadata);
    // Convert string representation of map back to actual map
    // Remove the curly braces and split by comma
    final pairs = decodedString
        .substring(1, decodedString.length - 1)
        .split(',')
        .map((pair) => pair.trim().split(':'))
        .where((pair) => pair.length == 2)
        .map((pair) => MapEntry(
              pair[0].trim(),
              pair[1].trim(),
            ));
    return Map.fromEntries(pairs);
  }

  VehicleDocument copyWith({
    int? id,
    int? vehicleId,
    String? title,
    String? type,
    String? filePath,
    DateTime? date,
    String? description,
    double? amount,
    Map<String, dynamic>? metadata,
  }) {
    return VehicleDocument(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      date: date ?? this.date,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      metadata: metadata ?? this.metadata,
    );
  }
}
