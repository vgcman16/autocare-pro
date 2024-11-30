import 'package:flutter/cupertino.dart';
import '../models/vehicle.dart';
import 'add_vehicle_screen.dart';
import 'vehicle_details_screen.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final List<Vehicle> _vehicles = [
    Vehicle(
      make: 'Chevrolet',
      model: 'Traverse',
      year: 2011,
      vin: 'SAMPLE_VIN_1',
      mileage: 120000,
    ),
    Vehicle(
      make: 'Dodge',
      model: 'Caravan',
      year: 2011,
      vin: 'SAMPLE_VIN_2',
      mileage: 150000,
    ),
    Vehicle(
      make: 'Lincoln',
      model: 'Unknown',
      year: 2007,
      vin: 'SAMPLE_VIN_3',
      mileage: 180000,
    ),
  ];

  void _addVehicle() async {
    final result = await Navigator.push<Vehicle>(
      context,
      CupertinoPageRoute(
        builder: (context) => const AddVehicleScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _vehicles.add(result);
      });
    }
  }

  void _viewVehicleDetails(Vehicle vehicle) async {
    final shouldDelete = await Navigator.push<bool>(
      context,
      CupertinoPageRoute(
        builder: (context) => VehicleDetailsScreen(vehicle: vehicle),
      ),
    );

    if (shouldDelete == true) {
      setState(() {
        _vehicles.removeWhere((v) => 
          v.make == vehicle.make && 
          v.model == vehicle.model && 
          v.year == vehicle.year && 
          v.vin == vehicle.vin
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('My Vehicles'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: _addVehicle,
        ),
      ),
      child: SafeArea(
        child: _vehicles.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.car_detailed,
                      size: 48,
                      color: CupertinoColors.systemGrey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No vehicles yet',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add a vehicle',
                      style: TextStyle(
                        color: CupertinoColors.systemGrey.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : ListView(
                children: _vehicles
                    .map((vehicle) => _buildVehicleCard(vehicle))
                    .toList(),
              ),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return GestureDetector(
      onTap: () => _viewVehicleDetails(vehicle),
      child: Container(
        margin: const EdgeInsets.all(8.0),
        child: CupertinoListSection.insetGrouped(
          children: [
            CupertinoListTile(
              title: Text('${vehicle.year} ${vehicle.make} ${vehicle.model}'),
              subtitle: Text('Mileage: ${vehicle.mileage}'),
              trailing: const CupertinoListTileChevron(),
            ),
          ],
        ),
      ),
    );
  }
}
