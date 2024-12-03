import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../screens/vehicle_details_screen.dart';

class MaintenanceOverviewScreen extends StatefulWidget {
  final VoidCallback? onBack;
  
  const MaintenanceOverviewScreen({super.key, this.onBack});

  @override
  State<MaintenanceOverviewScreen> createState() => _MaintenanceOverviewScreenState();
}

class _MaintenanceOverviewScreenState extends State<MaintenanceOverviewScreen> {
  final _vehicleService = VehicleService();
  List<Vehicle> _vehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final vehicles = await _vehicleService.getVehicles();
      if (!mounted) return;
      
      setState(() {
        _vehicles = vehicles;
        _isLoading = false;
      });
      
      // Debug print
      print('Loaded ${vehicles.length} vehicles: $vehicles');
      
    } catch (e, stackTrace) {
      print('Error loading vehicles: $e\n$stackTrace');
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading vehicles: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.onBack != null) {
          widget.onBack!();
          return false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Maintenance Overview'),
          leading: widget.onBack != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: widget.onBack,
                )
              : null,
        ),
        body: RefreshIndicator(
          onRefresh: _loadVehicles,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _vehicles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.directions_car_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No vehicles found',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              // TODO: Navigate to add vehicle screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Add a vehicle to get started')),
                              );
                            },
                            child: const Text('Add a Vehicle'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = _vehicles[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            leading: const Icon(Icons.build),
                            title: Text(vehicle.name),
                            subtitle: Text(
                              'Mileage: ${vehicle.mileage} miles',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VehicleDetailsScreen(vehicle: vehicle),
                                ),
                              ).then((_) => _loadVehicles());
                            },
                          ),
                        );
                      },
                    ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Navigate to add vehicle screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add a vehicle to get started')),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
