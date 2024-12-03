import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/fuel_record.dart';
import '../models/vehicle.dart';
import '../services/fuel_service.dart';
import '../services/vehicle_service.dart';
import 'add_fuel_record_screen.dart';

class FuelScreen extends StatefulWidget {
  final int vehicleId;

  const FuelScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  final _fuelService = FuelService();
  final _vehicleService = VehicleService();
  final _currencyFormat = NumberFormat.currency(symbol: '\$');
  
  List<FuelRecord> _fuelRecords = [];
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  String _selectedView = 'records'; // 'records', 'mpg', 'cost', 'locations'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final vehicles = await _vehicleService.getVehicles();
    if (vehicles.isNotEmpty) {
      _selectedVehicle ??= vehicles.firstWhere((v) => v.id == widget.vehicleId);
      final records = await _fuelService.getFuelRecords(
        vehicleId: _selectedVehicle!.id,
      );
      setState(() {
        _vehicles = vehicles;
        _fuelRecords = records;
      });
    }
  }

  Widget _buildVehicleSelector() {
    if (_vehicles.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          const Text('Vehicle: '),
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _selectedVehicle != null
                  ? '${_selectedVehicle!.year} ${_selectedVehicle!.make} ${_selectedVehicle!.model}'
                  : 'Select Vehicle',
            ),
            onPressed: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) => Container(
                  height: 216,
                  padding: const EdgeInsets.only(top: 6.0),
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  color: CupertinoColors.systemBackground.resolveFrom(context),
                  child: SafeArea(
                    top: false,
                    child: CupertinoPicker(
                      itemExtent: 32,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedVehicle = _vehicles[index];
                        });
                        _loadData();
                      },
                      children: _vehicles
                          .map((v) =>
                              Text('${v.year} ${v.make} ${v.model}'))
                          .toList(),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewSelector() {
    return CupertinoSlidingSegmentedControl<String>(
      children: const {
        'records': Text('Records'),
        'mpg': Text('MPG'),
        'cost': Text('Cost'),
        'locations': Text('Locations'),
      },
      groupValue: _selectedView,
      onValueChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedView = value;
          });
        }
      },
    );
  }

  Widget _buildRecordsList() {
    if (_fuelRecords.isEmpty) {
      return const Center(
        child: Text('No fuel records found'),
      );
    }

    return ListView.builder(
      itemCount: _fuelRecords.length,
      itemBuilder: (context, index) {
        final record = _fuelRecords[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: CupertinoColors.systemGrey.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CupertinoListTile(
            title: Text(DateFormat.yMMMd().format(record.date)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${record.gallons.toStringAsFixed(3)} gallons'),
                Text(_currencyFormat.format(record.cost)),
                if (record.location != null) Text(record.location!),
              ],
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.ellipsis),
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => CupertinoActionSheet(
                    actions: [
                      CupertinoActionSheetAction(
                        child: const Text('Edit'),
                        onPressed: () {
                          Navigator.pop(context);
                          _editRecord(record);
                        },
                      ),
                      CupertinoActionSheetAction(
                        isDestructiveAction: true,
                        child: const Text('Delete'),
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteRecord(record);
                        },
                      ),
                    ],
                    cancelButton: CupertinoActionSheetAction(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMPGChart() {
    if (_fuelRecords.isEmpty) {
      return const Center(
        child: Text('No data available for MPG analysis'),
      );
    }

    return FutureBuilder<List<MapEntry<DateTime, double>>>(
      future: _fuelService.getFuelEfficiencyTrend(
        _selectedVehicle!.id!,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No MPG data available'),
          );
        }

        final data = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= data.length) {
                          return const Text('');
                        }
                        return Text(
                          DateFormat.MMMd().format(data[value.toInt()].key),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((entry) {
                      return FlSpot(
                        entry.key.toDouble(),
                        entry.value.value,
                      );
                    }).toList(),
                    isCurved: true,
                    color: CupertinoColors.activeBlue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: CupertinoColors.activeBlue.withOpacity(0.1),
                    ),
                  ),
                ],
                minY: 0,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCostChart() {
    if (_fuelRecords.isEmpty) {
      return const Center(
        child: Text('No data available for cost analysis'),
      );
    }

    return FutureBuilder<Map<String, double>>(
      future: _fuelService.getFuelCostsByMonth(_selectedVehicle!.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No cost data available'),
          );
        }

        final data = snapshot.data!;
        final sortedEntries = data.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value < 0 || value >= sortedEntries.length) {
                          return const Text('');
                        }
                        final date = sortedEntries[value.toInt()].key;
                        return Text(
                          date.substring(5), // Show only MM part
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: sortedEntries.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.value,
                        color: CupertinoColors.activeBlue,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ],
                  );
                }).toList(),
                minY: 0,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationsList() {
    if (_fuelRecords.isEmpty) {
      return const Center(
        child: Text('No data available for location analysis'),
      );
    }

    return FutureBuilder<Map<String, double>>(
      future: _fuelService.getAveragePriceByLocation(_selectedVehicle!.id!),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No location data available'),
          );
        }

        final data = snapshot.data!;
        final sortedEntries = data.entries.toList()
          ..sort((a, b) => a.value.compareTo(b.value));

        return ListView.builder(
          itemCount: sortedEntries.length,
          itemBuilder: (context, index) {
            final entry = sortedEntries[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: CupertinoColors.systemGrey.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CupertinoListTile(
                title: Text(entry.key),
                subtitle: Text(
                  'Average: ${_currencyFormat.format(entry.value)}/gallon',
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _addRecord() async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AddFuelRecordScreen(
          vehicles: _vehicles,
          selectedVehicle: _selectedVehicle,
        ),
      ),
    );
    _loadData();
  }

  Future<void> _editRecord(FuelRecord record) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AddFuelRecordScreen(
          vehicles: _vehicles,
          selectedVehicle: _selectedVehicle,
          record: record,
        ),
      ),
    );
    _loadData();
  }

  Future<void> _deleteRecord(FuelRecord record) async {
    await _fuelService.deleteFuelRecord(record.id!);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (_vehicles.isEmpty) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Fuel Tracking'),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Please add a vehicle first',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                CupertinoButton.filled(
                  child: const Text('Add Vehicle'),
                  onPressed: () {
                    // Navigate to add vehicle screen
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Fuel Tracking'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: _addRecord,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildVehicleSelector(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildViewSelector(),
            ),
            Expanded(
              child: _selectedView == 'records'
                  ? _buildRecordsList()
                  : _selectedView == 'mpg'
                      ? _buildMPGChart()
                      : _selectedView == 'cost'
                          ? _buildCostChart()
                          : _buildLocationsList(),
            ),
          ],
        ),
      ),
    );
  }
}
