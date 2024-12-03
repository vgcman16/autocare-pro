import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import 'add_vehicle_screen.dart';
import 'vehicle_details_screen.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final VehicleService _vehicleService = VehicleService();
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
      
      print('Loaded ${vehicles.length} vehicles');
    } catch (e, stackTrace) {
      print('Error loading vehicles: $e\n$stackTrace');
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Error'),
          content: Text('Failed to load vehicles: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _addVehicle() async {
    final result = await Navigator.push<Vehicle>(
      context,
      CupertinoPageRoute(
        builder: (context) => const AddVehicleScreen(),
      ),
    );

    if (result != null && mounted) {
      await _loadVehicles(); // Reload the entire list to ensure consistency
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Vehicles'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _addVehicle,
          child: const Icon(CupertinoIcons.add),
        ),
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : _vehicles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          CupertinoIcons.car_detailed,
                          size: 64,
                          color: CupertinoColors.systemGrey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No vehicles found',
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        CupertinoButton(
                          child: const Text('Add a Vehicle'),
                          onPressed: _addVehicle,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadVehicles,
                    child: ListView.builder(
                      itemCount: _vehicles.length,
                      itemBuilder: (context, index) {
                        final vehicle = _vehicles[index];
                        return CupertinoListTile(
                          title: Text('${vehicle.year} ${vehicle.make} ${vehicle.model}'),
                          subtitle: Text('Mileage: ${vehicle.mileage} miles'),
                          trailing: const CupertinoListTileChevron(),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => VehicleDetailsScreen(vehicle: vehicle),
                              ),
                            );
                            if (mounted) {
                              await _loadVehicles(); // Reload after returning from details
                            }
                          },
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}
