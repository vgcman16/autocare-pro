class MaintenanceRecord {
  final int? id;
  final int vehicleId;
  final String serviceType;
  final DateTime date;
  final int mileage;
  final String? notes;
  final double? cost;

  MaintenanceRecord({
    this.id,
    required this.vehicleId,
    required this.serviceType,
    required this.date,
    required this.mileage,
    this.notes,
    this.cost,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'service_type': serviceType,
      'date': date.toIso8601String(),
      'mileage': mileage,
      'notes': notes,
      'cost': cost,
    };
  }

  factory MaintenanceRecord.fromMap(Map<String, dynamic> map) {
    return MaintenanceRecord(
      id: map['id'],
      vehicleId: map['vehicle_id'],
      serviceType: map['service_type'],
      date: DateTime.parse(map['date']),
      mileage: map['mileage'],
      notes: map['notes'],
      cost: map['cost'] != null ? (map['cost'] as num).toDouble() : null,
    );
  }

  MaintenanceRecord copyWith({
    int? id,
    int? vehicleId,
    String? serviceType,
    DateTime? date,
    int? mileage,
    String? notes,
    double? cost,
  }) {
    return MaintenanceRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      serviceType: serviceType ?? this.serviceType,
      date: date ?? this.date,
      mileage: mileage ?? this.mileage,
      notes: notes ?? this.notes,
      cost: cost ?? this.cost,
    );
  }
}
