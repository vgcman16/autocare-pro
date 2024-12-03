import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../services/fuel_service.dart';
import '../models/fuel_record.dart';
import 'add_fuel_record_screen.dart';

class FuelOverviewScreen extends StatefulWidget {
  const FuelOverviewScreen({super.key});

  @override
  State<FuelOverviewScreen> createState() => _FuelOverviewScreenState();
}

class _FuelOverviewScreenState extends State<FuelOverviewScreen> {
  final _vehicleService = VehicleService();
  final _fuelService = FuelService();
  List<Vehicle> _vehicles = [];
  Map<int, double> _latestMPG = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final vehicles = await _vehicleService.getVehicles();
      if (!mounted) return;

      final mpgData = <int, double>{};
      
      for (final vehicle in vehicles) {
        if (vehicle.id != null) {
          try {
            final mpg = await _fuelService.getAverageMPG(
              vehicle.id!,
              startDate: DateTime.now().subtract(const Duration(days: 30)),
            );
            mpgData[vehicle.id!] = mpg;
          } catch (e) {
            print('Error getting MPG for vehicle ${vehicle.id}: $e');
            mpgData[vehicle.id!] = 0.0;
          }
        }
      }

      if (!mounted) return;

      setState(() {
        _vehicles = vehicles;
        _latestMPG = mpgData;
        _isLoading = false;
      });
      
      print('Loaded ${vehicles.length} vehicles with MPG data: $mpgData');
      
    } catch (e, stackTrace) {
      print('Error loading fuel overview data: $e\n$stackTrace');
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addFuelRecord(Vehicle vehicle) async {
    final result = await Navigator.push<FuelRecord>(
      context,
      MaterialPageRoute(
        builder: (context) => AddFuelRecordScreen(
          vehicles: _vehicles,
          selectedVehicle: vehicle,
        ),
      ),
    );

    if (result != null && mounted) {
      await _loadData(); // Reload data to update MPG
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuel Overview'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading data',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _vehicles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.local_gas_station,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No vehicles found',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Add a vehicle to track fuel efficiency',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        itemCount: _vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = _vehicles[index];
                          final mpg = vehicle.id != null ? _latestMPG[vehicle.id] ?? 0.0 : 0.0;
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.local_gas_station),
                              title: Text(vehicle.name),
                              subtitle: Text(
                                mpg > 0
                                    ? '30-day average: ${mpg.toStringAsFixed(1)} MPG'
                                    : 'No fuel records in the last 30 days',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _addFuelRecord(vehicle),
                                tooltip: 'Add fuel record',
                              ),
                              onTap: () => _addFuelRecord(vehicle),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
