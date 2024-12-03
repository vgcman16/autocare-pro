import '../models/fuel_record.dart';
import 'database_service.dart';

class FuelService {
  final DatabaseService _db = DatabaseService();

  Future<List<FuelRecord>> getFuelRecords({int? vehicleId}) async {
    final records = await _db.getFuelRecords(vehicleId: vehicleId);
    return records;
  }

  Future<FuelRecord> addFuelRecord(FuelRecord record) async {
    final id = await _db.insertFuelRecord(record);
    return record.copyWith(id: id);
  }

  Future<bool> updateFuelRecord(FuelRecord record) async {
    final result = await _db.updateFuelRecord(record);
    return result > 0;
  }

  Future<bool> deleteFuelRecord(int id) async {
    final result = await _db.deleteFuelRecord(id);
    return result > 0;
  }

  Future<double> getAverageMPG(int vehicleId, {DateTime? startDate, DateTime? endDate}) async {
    final records = await getFuelRecords(vehicleId: vehicleId);
    if (records.length < 2) return 0.0;

    var filteredRecords = records.where((record) {
      if (startDate != null && record.date.isBefore(startDate)) return false;
      if (endDate != null && record.date.isAfter(endDate)) return false;
      return true;
    }).toList();

    filteredRecords.sort((a, b) => a.odometer.compareTo(b.odometer));

    double totalMiles = 0.0;
    double totalGallons = 0.0;

    for (int i = 1; i < filteredRecords.length; i++) {
      if (!filteredRecords[i - 1].isPartialFill && !filteredRecords[i].isPartialFill) {
        final miles = filteredRecords[i].odometer - filteredRecords[i - 1].odometer;
        totalMiles += miles;
        totalGallons += filteredRecords[i].gallons;
      }
    }

    return totalGallons > 0 ? totalMiles / totalGallons : 0.0;
  }

  Future<Map<String, double>> getFuelCostsByMonth(int vehicleId, {int monthsBack = 12}) async {
    final records = await getFuelRecords(vehicleId: vehicleId);
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - monthsBack + 1);

    final costsByMonth = <String, double>{};
    
    for (var record in records) {
      if (record.date.isAfter(startDate)) {
        final monthKey = '${record.date.year}-${record.date.month.toString().padLeft(2, '0')}';
        costsByMonth[monthKey] = (costsByMonth[monthKey] ?? 0.0) + record.cost;
      }
    }

    return costsByMonth;
  }

  Future<Map<String, double>> getAveragePriceByLocation(int vehicleId) async {
    final records = await getFuelRecords(vehicleId: vehicleId);
    final pricesByLocation = <String, List<double>>{};

    for (var record in records) {
      if (record.location != null) {
        pricesByLocation.putIfAbsent(record.location!, () => []);
        pricesByLocation[record.location]!.add(record.pricePerGallon);
      }
    }

    return Map.fromEntries(
      pricesByLocation.entries.map(
        (entry) => MapEntry(
          entry.key,
          entry.value.reduce((a, b) => a + b) / entry.value.length,
        ),
      ),
    );
  }

  Future<List<MapEntry<DateTime, double>>> getFuelEfficiencyTrend(
    int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final records = await getFuelRecords(vehicleId: vehicleId);
    if (records.length < 2) return [];

    var filteredRecords = records.where((record) {
      if (startDate != null && record.date.isBefore(startDate)) return false;
      if (endDate != null && record.date.isAfter(endDate)) return false;
      return true;
    }).toList();

    filteredRecords.sort((a, b) => a.date.compareTo(b.date));

    final efficiencyTrend = <MapEntry<DateTime, double>>[];

    for (int i = 1; i < filteredRecords.length; i++) {
      if (!filteredRecords[i - 1].isPartialFill && !filteredRecords[i].isPartialFill) {
        final miles = filteredRecords[i].odometer - filteredRecords[i - 1].odometer;
        final gallons = filteredRecords[i].gallons;
        if (gallons > 0) {
          final mpg = miles / gallons;
          efficiencyTrend.add(MapEntry(filteredRecords[i].date, mpg.toDouble()));
        }
      }
    }

    return efficiencyTrend;
  }
}
