class Vehicle {
  final int? id;
  final String make;
  final String model;
  final int year;
  final int mileage;
  final String? vin;
  final String? imageUrl;

  Vehicle({
    this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.mileage,
    this.vin,
    this.imageUrl,
  });

  String get name => '$year $make $model';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'make': make,
      'model': model,
      'year': year,
      'vin': vin,
      'mileage': mileage,
      'imageUrl': imageUrl,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'],
      make: map['make'],
      model: map['model'],
      year: map['year'],
      vin: map['vin'],
      mileage: map['mileage'],
      imageUrl: map['imageUrl'],
    );
  }

  Vehicle copyWith({
    int? id,
    String? make,
    String? model,
    int? year,
    int? mileage,
    String? vin,
    String? imageUrl,
  }) {
    return Vehicle(
      id: id ?? this.id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      mileage: mileage ?? this.mileage,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
