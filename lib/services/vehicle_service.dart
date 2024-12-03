import '../models/vehicle.dart';
import 'database_service.dart';

class VehicleService {
  final DatabaseService _db = DatabaseService();

  // Get all vehicles
  Future<List<Vehicle>> getVehicles() async {
    return await _db.getVehicles();
  }

  // Add a new vehicle
  Future<Vehicle> addVehicle(Vehicle vehicle) async {
    final id = await _db.insertVehicle(vehicle);
    return vehicle.copyWith(id: id);
  }

  // Update an existing vehicle
  Future<bool> updateVehicle(Vehicle vehicle) async {
    final rowsAffected = await _db.updateVehicle(vehicle);
    return rowsAffected > 0;
  }

  // Delete a vehicle
  Future<bool> deleteVehicle(int id) async {
    final rowsAffected = await _db.deleteVehicle(id);
    return rowsAffected > 0;
  }
}
