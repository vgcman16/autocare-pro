import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../models/maintenance_record.dart';
import '../services/maintenance_record_service.dart';
import '../screens/documents_screen.dart';
import '../screens/maintenance_screen.dart';
import '../screens/fuel_screen.dart';
import 'package:intl/intl.dart';

class VehicleDetailsScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({
    Key? key,
    required this.vehicle,
  }) : super(key: key);

  @override
  State<VehicleDetailsScreen> createState() => _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends State<VehicleDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MaintenanceRecordService _maintenanceService = MaintenanceRecordService();
  List<MaintenanceRecord>? _recentServices;
  double _totalExpenses = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final records = await _maintenanceService.getRecords(vehicleId: widget.vehicle.id!);
    final expenses = await _maintenanceService.getTotalExpenses(
      widget.vehicle.id!,
      startDate: DateTime(DateTime.now().year),
    );

    if (mounted) {
      setState(() {
        _recentServices = records;
        _totalExpenses = expenses;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.vehicle.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Details'),
            Tab(icon: Icon(Icons.build), text: 'Maintenance'),
            Tab(icon: Icon(Icons.local_gas_station), text: 'Fuel'),
            Tab(icon: Icon(Icons.folder), text: 'Documents'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          MaintenanceScreen(vehicleId: widget.vehicle.id!),
          FuelScreen(vehicleId: widget.vehicle.id!),
          DocumentsScreen(vehicleId: widget.vehicle.id!),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildBasicInfo(),
        const SizedBox(height: 20),
        _buildServiceHistory(),
        const SizedBox(height: 20),
        _buildExpenses(),
        const SizedBox(height: 20),
        // _buildDocuments(),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Make', widget.vehicle.make),
            _buildInfoRow('Model', widget.vehicle.model),
            _buildInfoRow('Year', widget.vehicle.year.toString()),
            if (widget.vehicle.vin != null) 
              _buildInfoRow('VIN', widget.vehicle.vin!),
            _buildInfoRow('Mileage', '${widget.vehicle.mileage} miles'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHistory() {
    if (_recentServices == null) {
      return const Card(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final recentServices = List<MaintenanceRecord>.from(_recentServices!)
      ..sort((a, b) => b.date.compareTo(a.date));

    if (recentServices.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text('No service records found'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...recentServices.take(3).map((record) {
              final mileageDiff = widget.vehicle.mileage - record.mileage;
              return ListTile(
                title: Text(record.serviceType),
                subtitle: Text(
                  '${DateFormat.yMMMd().format(record.date)}\n$mileageDiff miles ago',
                ),
                trailing: record.cost != null
                    ? Text('\$${record.cost!.toStringAsFixed(2)}')
                    : null,
              );
            }).toList(),
            if (recentServices.length > 3)
              ListTile(
                title: const Text('View All Services'),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  _tabController.animateTo(1); // Switch to Maintenance tab
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenses() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expenses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Total Expenses (${DateTime.now().year})'),
              trailing: Text('\$${_totalExpenses.toStringAsFixed(2)}'),
            ),
            ListTile(
              title: const Text('View All Expenses'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                _tabController.animateTo(1); // Switch to Maintenance tab
              },
            ),
          ],
        ),
      ),
    );
  }
}
