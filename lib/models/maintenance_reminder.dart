class MaintenanceReminder {
  final int? id;
  final int vehicleId;
  final String title;
  final String description;
  final DateTime dueDate;
  final int? dueMileage;
  final bool isCompleted;
  final String frequency; // 'once', 'monthly', 'yearly', 'mileage'
  final int? repeatMiles; // For mileage-based reminders

  MaintenanceReminder({
    this.id,
    required this.vehicleId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.dueMileage,
    this.isCompleted = false,
    required this.frequency,
    this.repeatMiles,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'dueMileage': dueMileage,
      'isCompleted': isCompleted ? 1 : 0,
      'frequency': frequency,
      'repeatMiles': repeatMiles,
    };
  }

  factory MaintenanceReminder.fromMap(Map<String, dynamic> map) {
    return MaintenanceReminder(
      id: map['id'],
      vehicleId: map['vehicleId'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      dueMileage: map['dueMileage'],
      isCompleted: map['isCompleted'] == 1,
      frequency: map['frequency'],
      repeatMiles: map['repeatMiles'],
    );
  }

  MaintenanceReminder copyWith({
    int? id,
    int? vehicleId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? dueMileage,
    bool? isCompleted,
    String? frequency,
    int? repeatMiles,
  }) {
    return MaintenanceReminder(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueMileage: dueMileage ?? this.dueMileage,
      isCompleted: isCompleted ?? this.isCompleted,
      frequency: frequency ?? this.frequency,
      repeatMiles: repeatMiles ?? this.repeatMiles,
    );
  }
}
