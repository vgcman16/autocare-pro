class Trip {
  final int? id;
  final int vehicleId;
  final DateTime startTime;
  final DateTime? endTime;
  final String? startLocation;
  final String? endLocation;
  final double? startOdometer;
  final double? endOdometer;
  final String tripType; // 'business' or 'personal'
  final String? purpose;
  final double? fuelCost;
  final String? notes;
  final List<String>? routePoints; // List of lat,lng points for the route

  Trip({
    this.id,
    required this.vehicleId,
    required this.startTime,
    this.endTime,
    this.startLocation,
    this.endLocation,
    this.startOdometer,
    this.endOdometer,
    required this.tripType,
    this.purpose,
    this.fuelCost,
    this.notes,
    this.routePoints,
  });

  double? get distance => 
    (endOdometer != null && startOdometer != null) 
      ? endOdometer! - startOdometer!
      : null;

  Duration? get duration =>
    endTime != null ? endTime!.difference(startTime) : null;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicle_id': vehicleId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'start_location': startLocation,
      'end_location': endLocation,
      'start_odometer': startOdometer,
      'end_odometer': endOdometer,
      'trip_type': tripType,
      'purpose': purpose,
      'fuel_cost': fuelCost,
      'notes': notes,
      'route_points': routePoints != null ? routePoints!.join('|') : null,
    };
  }

  factory Trip.fromMap(Map<String, dynamic> map) {
    return Trip(
      id: map['id'],
      vehicleId: map['vehicle_id'],
      startTime: DateTime.parse(map['start_time']),
      endTime: map['end_time'] != null ? DateTime.parse(map['end_time']) : null,
      startLocation: map['start_location'],
      endLocation: map['end_location'],
      startOdometer: map['start_odometer'],
      endOdometer: map['end_odometer'],
      tripType: map['trip_type'],
      purpose: map['purpose'],
      fuelCost: map['fuel_cost'],
      notes: map['notes'],
      routePoints: map['route_points'] != null 
        ? map['route_points'].split('|')
        : null,
    );
  }

  Trip copyWith({
    int? id,
    int? vehicleId,
    DateTime? startTime,
    DateTime? endTime,
    String? startLocation,
    String? endLocation,
    double? startOdometer,
    double? endOdometer,
    String? tripType,
    String? purpose,
    double? fuelCost,
    String? notes,
    List<String>? routePoints,
  }) {
    return Trip(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      startOdometer: startOdometer ?? this.startOdometer,
      endOdometer: endOdometer ?? this.endOdometer,
      tripType: tripType ?? this.tripType,
      purpose: purpose ?? this.purpose,
      fuelCost: fuelCost ?? this.fuelCost,
      notes: notes ?? this.notes,
      routePoints: routePoints ?? this.routePoints,
    );
  }
}
