class FuelRecord {
  final int? id;
  final int vehicleId;
  final DateTime date;
  final double gallons;
  final double cost;
  final double odometer;
  final String? station;
  final String? location;
  final bool isPartialFill;
  final String? notes;

  FuelRecord({
    this.id,
    required this.vehicleId,
    required this.date,
    required this.gallons,
    required this.cost,
    required this.odometer,
    this.station,
    this.location,
    this.isPartialFill = false,
    this.notes,
  });

  double get pricePerGallon => cost / gallons;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'date': date.toIso8601String(),
      'gallons': gallons,
      'cost': cost,
      'odometer': odometer,
      'station': station,
      'location': location,
      'isPartialFill': isPartialFill ? 1 : 0,
      'notes': notes,
    };
  }

  factory FuelRecord.fromMap(Map<String, dynamic> map) {
    return FuelRecord(
      id: map['id'],
      vehicleId: map['vehicleId'],
      date: DateTime.parse(map['date']),
      gallons: (map['gallons'] as num).toDouble(),
      cost: (map['cost'] as num).toDouble(),
      odometer: (map['odometer'] as num).toDouble(),
      station: map['station'],
      location: map['location'],
      isPartialFill: map['isPartialFill'] == 1,
      notes: map['notes'],
    );
  }

  FuelRecord copyWith({
    int? id,
    int? vehicleId,
    DateTime? date,
    double? gallons,
    double? cost,
    double? odometer,
    String? station,
    String? location,
    bool? isPartialFill,
    String? notes,
  }) {
    return FuelRecord(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      date: date ?? this.date,
      gallons: gallons ?? this.gallons,
      cost: cost ?? this.cost,
      odometer: odometer ?? this.odometer,
      station: station ?? this.station,
      location: location ?? this.location,
      isPartialFill: isPartialFill ?? this.isPartialFill,
      notes: notes ?? this.notes,
    );
  }
}
