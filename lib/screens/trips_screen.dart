import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';
import 'add_trip_screen.dart';

class TripsScreen extends StatefulWidget {
  final int vehicleId;

  const TripsScreen({
    Key? key,
    required this.vehicleId,
  }) : super(key: key);

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  final TripService _tripService = TripService();
  String _selectedTripType = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  Map<String, double>? _statistics;
  Trip? _currentTrip;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final stats = await _tripService.getTripStatistics(
      widget.vehicleId,
      startDate: _startDate,
      endDate: _endDate,
      tripType: _selectedTripType == 'all' ? null : _selectedTripType,
    );

    final currentTrip = await _tripService.getCurrentTrip(widget.vehicleId);

    if (mounted) {
      setState(() {
        _statistics = stats;
        _currentTrip = currentTrip;
      });
    }
  }

  Widget _buildStatisticsCard() {
    if (_statistics == null) {
      return const Card(
        child: Center(
          child: CircularProgressIndicator(),
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
              'Trip Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatRow('Total Distance', '${_statistics!['totalDistance']?.toStringAsFixed(1)} miles'),
            _buildStatRow('Total Cost', '\$${_statistics!['totalCost']?.toStringAsFixed(2)}'),
            _buildStatRow('Total Trips', '${_statistics!['totalTrips']?.toInt()}'),
            _buildStatRow('Average Trip Distance', '${_statistics!['averageTripDistance']?.toStringAsFixed(1)} miles'),
            _buildStatRow('Average Trip Cost', '\$${_statistics!['averageTripCost']?.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildCurrentTripCard() {
    if (_currentTrip == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Current Trip',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  _currentTrip!.tripType.toUpperCase(),
                  style: TextStyle(
                    color: _currentTrip!.tripType == 'business'
                        ? Colors.blue
                        : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Started: ${DateFormat.yMMMd().add_jm().format(_currentTrip!.startTime)}'),
            if (_currentTrip!.startLocation != null)
              Text('From: ${_currentTrip!.startLocation}'),
            if (_currentTrip!.purpose != null)
              Text('Purpose: ${_currentTrip!.purpose}'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    final updatedTrip = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTripScreen(
                          vehicleId: widget.vehicleId,
                          trip: _currentTrip,
                        ),
                      ),
                    );
                    if (updatedTrip != null) {
                      _loadData();
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Show dialog to enter end odometer and fuel cost
                    final result = await showDialog<Map<String, double>>(
                      context: context,
                      builder: (context) => _EndTripDialog(),
                    );
                    
                    if (result != null) {
                      await _tripService.endTrip(
                        _currentTrip!,
                        endOdometer: result['odometer'],
                        fuelCost: result['fuelCost'],
                      );
                      _loadData();
                    }
                  },
                  icon: const Icon(Icons.stop),
                  label: const Text('End Trip'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trips'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedTripType = value;
              });
              _loadData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('All Trips'),
              ),
              const PopupMenuItem(
                value: 'business',
                child: Text('Business Trips'),
              ),
              const PopupMenuItem(
                value: 'personal',
                child: Text('Personal Trips'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<Trip>>(
        stream: Stream.fromFuture(_tripService.getTrips(
          vehicleId: widget.vehicleId,
          startDate: _startDate,
          endDate: _endDate,
          tripType: _selectedTripType == 'all' ? null : _selectedTripType,
        )),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final trips = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildCurrentTripCard(),
              const SizedBox(height: 16),
              _buildStatisticsCard(),
              const SizedBox(height: 16),
              ...trips.where((trip) => trip.endTime != null).map((trip) {
                final duration = trip.duration;
                final distance = trip.distance;

                return Card(
                  child: ListTile(
                    title: Text(DateFormat.yMMMd().format(trip.startTime)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (trip.purpose != null)
                          Text(trip.purpose!),
                        if (duration != null)
                          Text('Duration: ${duration.inHours}h ${duration.inMinutes % 60}m'),
                        if (distance != null)
                          Text('Distance: ${distance.toStringAsFixed(1)} miles'),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          trip.tripType.toUpperCase(),
                          style: TextStyle(
                            color: trip.tripType == 'business'
                                ? Colors.blue
                                : Colors.green,
                          ),
                        ),
                        if (trip.fuelCost != null)
                          Text('\$${trip.fuelCost!.toStringAsFixed(2)}'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTripScreen(
                            vehicleId: widget.vehicleId,
                            trip: trip,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
      floatingActionButton: _currentTrip == null
          ? FloatingActionButton(
              onPressed: () async {
                final newTrip = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTripScreen(
                      vehicleId: widget.vehicleId,
                    ),
                  ),
                );
                if (newTrip != null) {
                  _loadData();
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _EndTripDialog extends StatefulWidget {
  @override
  State<_EndTripDialog> createState() => _EndTripDialogState();
}

class _EndTripDialogState extends State<_EndTripDialog> {
  final _formKey = GlobalKey<FormState>();
  final _odometerController = TextEditingController();
  final _fuelCostController = TextEditingController();

  @override
  void dispose() {
    _odometerController.dispose();
    _fuelCostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('End Trip'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _odometerController,
              decoration: const InputDecoration(
                labelText: 'End Odometer Reading',
                suffixText: 'miles',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the odometer reading';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _fuelCostController,
              decoration: const InputDecoration(
                labelText: 'Fuel Cost (optional)',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'odometer': double.parse(_odometerController.text),
                'fuelCost': _fuelCostController.text.isNotEmpty
                    ? double.parse(_fuelCostController.text)
                    : null,
              });
            }
          },
          child: const Text('End Trip'),
        ),
      ],
    );
  }
}
