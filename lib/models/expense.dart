class Expense {
  final int? id;
  final String description;
  final double amount;
  final DateTime date;
  final int vehicleId;
  final String category;
  final String? notes;

  Expense({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.vehicleId,
    required this.category,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date.toIso8601String(),
      'vehicleId': vehicleId,
      'category': category,
      'notes': notes,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      vehicleId: map['vehicleId'],
      category: map['category'],
      notes: map['notes'],
    );
  }
}
