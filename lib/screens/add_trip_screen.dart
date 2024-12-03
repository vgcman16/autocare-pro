import 'package:flutter/material.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';

class AddTripScreen extends StatefulWidget {
  final int vehicleId;
  final Trip? trip;

  const AddTripScreen({
    Key? key,
    required this.vehicleId,
    this.trip,
  }) : super(key: key);

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tripService = TripService();
  
  late final TextEditingController _purposeController;
  late final TextEditingController _startOdometerController;
  late final TextEditingController _notesController;
  late String _tripType;

  @override
  void initState() {
    super.initState();
    _purposeController = TextEditingController(text: widget.trip?.purpose);
    _startOdometerController = TextEditingController(
      text: widget.trip?.startOdometer?.toString(),
    );
    _notesController = TextEditingController(text: widget.trip?.notes);
    _tripType = widget.trip?.tripType ?? 'business';
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _startOdometerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _startTrip() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final trip = await _tripService.startTrip(
        vehicleId: widget.vehicleId,
        tripType: _tripType,
        purpose: _purposeController.text,
        startOdometer: _startOdometerController.text.isNotEmpty
            ? double.parse(_startOdometerController.text)
            : null,
      );

      if (mounted) {
        Navigator.pop(context, trip);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error starting trip: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.trip == null ? 'Start Trip' : 'Edit Trip'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Type',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'business',
                          label: Text('Business'),
                          icon: Icon(Icons.business),
                        ),
                        ButtonSegment<String>(
                          value: 'personal',
                          label: Text('Personal'),
                          icon: Icon(Icons.person),
                        ),
                      ],
                      selected: {_tripType},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _tripType = newSelection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trip Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _purposeController,
                      decoration: const InputDecoration(
                        labelText: 'Purpose',
                        hintText: 'e.g., Client Meeting, Grocery Shopping',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the trip purpose';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _startOdometerController,
                      decoration: const InputDecoration(
                        labelText: 'Starting Odometer Reading',
                        hintText: 'Current mileage',
                        suffixText: 'miles',
                        border: OutlineInputBorder(),
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
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Additional details about the trip',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _startTrip,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.trip == null ? 'Start Trip' : 'Save Changes',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
