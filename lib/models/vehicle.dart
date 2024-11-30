class Vehicle {
  final int? id;
  final String make;
  final String model;
  final int year;
  final String vin;
  final int mileage;
  final String? imageUrl;

  Vehicle({
    this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.vin,
    required this.mileage,
    this.imageUrl,
  });

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
}
