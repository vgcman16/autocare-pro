import '../models/maintenance_record.dart';
import 'database_service.dart';

class MaintenanceRecordService {
  final DatabaseService _db = DatabaseService();

  Future<MaintenanceRecord> addRecord(MaintenanceRecord record) async {
    final id = await _db.insert('maintenance_records', record.toMap());
    return record.copyWith(id: id);
  }

  Future<List<MaintenanceRecord>> getRecords({int? vehicleId}) async {
    final records = await _db.query(
      'maintenance_records',
      where: vehicleId != null ? 'vehicle_id = ?' : null,
      whereArgs: vehicleId != null ? [vehicleId] : null,
    );
    return records.map((r) => MaintenanceRecord.fromMap(r)).toList();
  }

  Future<bool> updateRecord(MaintenanceRecord record) async {
    final result = await _db.update(
      'maintenance_records',
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
    return result > 0;
  }

  Future<bool> deleteRecord(int id) async {
    final result = await _db.delete(
      'maintenance_records',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result > 0;
  }

  Future<double> getTotalExpenses(int vehicleId, {DateTime? startDate, DateTime? endDate}) async {
    final records = await getRecords(vehicleId: vehicleId);
    double total = 0.0;
    
    for (final record in records) {
      if (record.cost != null) {
        if (startDate != null && record.date.isBefore(startDate)) continue;
        if (endDate != null && record.date.isAfter(endDate)) continue;
        total += record.cost!;
      }
    }
    
    return total;
  }

  Future<MaintenanceRecord?> getLastServiceByType(int vehicleId, String serviceType) async {
    final records = await getRecords(vehicleId: vehicleId);
    final filteredRecords = records
        .where((record) => record.serviceType == serviceType)
        .toList();
    
    if (filteredRecords.isEmpty) return null;
    
    filteredRecords.sort((a, b) => b.date.compareTo(a.date));
    return filteredRecords.first;
  }
}
