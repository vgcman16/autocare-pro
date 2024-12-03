import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/trip.dart';
import 'database_service.dart';

class TripService {
  final DatabaseService _db = DatabaseService();

  Future<Trip> startTrip({
    required int vehicleId,
    required String tripType,
    String? purpose,
    double? startOdometer,
  }) async {
    // Get current location
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
    // Get address from coordinates
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    
    final address = placemarks.isNotEmpty
        ? '${placemarks.first.street}, ${placemarks.first.locality}'
        : '${position.latitude},${position.longitude}';

    final trip = Trip(
      vehicleId: vehicleId,
      startTime: DateTime.now(),
      startLocation: address,
      startOdometer: startOdometer,
      tripType: tripType,
      purpose: purpose,
      routePoints: ['${position.latitude},${position.longitude}'],
    );

    final id = await _db.insert('trips', trip.toMap());
    return trip.copyWith(id: id);
  }

  Future<Trip> endTrip(Trip trip, {double? endOdometer, double? fuelCost}) async {
    // Get current location
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
    // Get address from coordinates
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    
    final address = placemarks.isNotEmpty
        ? '${placemarks.first.street}, ${placemarks.first.locality}'
        : '${position.latitude},${position.longitude}';

    // Add final location to route points
    final routePoints = List<String>.from(trip.routePoints ?? [])
      ..add('${position.latitude},${position.longitude}');

    final updatedTrip = trip.copyWith(
      endTime: DateTime.now(),
      endLocation: address,
      endOdometer: endOdometer,
      fuelCost: fuelCost,
      routePoints: routePoints,
    );

    await _db.update(
      'trips',
      updatedTrip.toMap(),
      where: 'id = ?',
      whereArgs: [trip.id],
    );

    return updatedTrip;
  }

  Future<void> updateTripLocation(Trip trip) async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final routePoints = List<String>.from(trip.routePoints ?? [])
      ..add('${position.latitude},${position.longitude}');

    await _db.update(
      'trips',
      {'route_points': routePoints.join('|')},
      where: 'id = ?',
      whereArgs: [trip.id],
    );
  }

  Future<List<Trip>> getTrips({
    int? vehicleId,
    DateTime? startDate,
    DateTime? endDate,
    String? tripType,
  }) async {
    String? where;
    List<dynamic>? whereArgs;

    if (vehicleId != null || startDate != null || endDate != null || tripType != null) {
      final conditions = <String>[];
      whereArgs = [];

      if (vehicleId != null) {
        conditions.add('vehicle_id = ?');
        whereArgs.add(vehicleId);
      }

      if (startDate != null) {
        conditions.add('start_time >= ?');
        whereArgs.add(startDate.toIso8601String());
      }

      if (endDate != null) {
        conditions.add('start_time <= ?');
        whereArgs.add(endDate.toIso8601String());
      }

      if (tripType != null) {
        conditions.add('trip_type = ?');
        whereArgs.add(tripType);
      }

      where = conditions.join(' AND ');
    }

    final trips = await _db.query(
      'trips',
      where: where,
      whereArgs: whereArgs,
    );

    // Sort the trips in memory instead of using orderBy
    final result = trips.map((t) => Trip.fromMap(t)).toList();
    result.sort((a, b) => b.startTime.compareTo(a.startTime));
    return result;
  }

  Future<Trip?> getCurrentTrip(int vehicleId) async {
    final trips = await _db.query(
      'trips',
      where: 'vehicle_id = ? AND end_time IS NULL',
      whereArgs: [vehicleId],
    );

    // Get the first trip if any exist
    return trips.isNotEmpty ? Trip.fromMap(trips.first) : null;
  }

  Future<Map<String, double>> getTripStatistics(int vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
    String? tripType,
  }) async {
    final trips = await getTrips(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
      tripType: tripType,
    );

    double totalDistance = 0;
    double totalCost = 0;
    int totalTrips = trips.length;

    for (final trip in trips) {
      if (trip.distance != null) {
        totalDistance += trip.distance!;
      }
      if (trip.fuelCost != null) {
        totalCost += trip.fuelCost!;
      }
    }

    return {
      'totalDistance': totalDistance,
      'totalCost': totalCost,
      'totalTrips': totalTrips.toDouble(),
      'averageTripDistance': totalTrips > 0 ? totalDistance / totalTrips : 0,
      'averageTripCost': totalTrips > 0 ? totalCost / totalTrips : 0,
    };
  }
}
