class MaintenanceTask {
  final int? id;
  final String title;
  final DateTime dueDate;
  final int dueMileage;
  final String notes;
  final int vehicleId;
  final bool isCompleted;

  MaintenanceTask({
    this.id,
    required this.title,
    required this.dueDate,
    required this.dueMileage,
    this.notes = '',
    required this.vehicleId,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate.toIso8601String(),
      'dueMileage': dueMileage,
      'notes': notes,
      'vehicleId': vehicleId,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory MaintenanceTask.fromMap(Map<String, dynamic> map) {
    return MaintenanceTask(
      id: map['id'],
      title: map['title'],
      dueDate: DateTime.parse(map['dueDate']),
      dueMileage: map['dueMileage'],
      notes: map['notes'],
      vehicleId: map['vehicleId'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
