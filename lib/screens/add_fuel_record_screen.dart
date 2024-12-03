import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/fuel_record.dart';
import '../models/vehicle.dart';
import '../services/fuel_service.dart';

class AddFuelRecordScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final FuelRecord? record;

  const AddFuelRecordScreen({
    super.key,
    required this.vehicles,
    this.selectedVehicle,
    this.record,
  });

  @override
  State<AddFuelRecordScreen> createState() => _AddFuelRecordScreenState();
}

class _AddFuelRecordScreenState extends State<AddFuelRecordScreen> {
  final _fuelService = FuelService();
  
  late Vehicle _selectedVehicle;
  late DateTime _date;
  final _gallonsController = TextEditingController();
  final _costController = TextEditingController();
  final _odometerController = TextEditingController();
  final _stationController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isPartialFill = false;

  bool _isEditing = false;
  bool _showErrors = false;
  String? _gallonsError;
  String? _costError;
  String? _odometerError;

  void _validateFields() {
    setState(() {
      _showErrors = true;
      _gallonsError = _gallonsController.text.isEmpty
          ? 'Required'
          : !_isValidNumber(_gallonsController.text)
              ? 'Enter a valid number'
              : null;
      _costError = _costController.text.isEmpty
          ? 'Required'
          : !_isValidNumber(_costController.text)
              ? 'Enter a valid number'
              : null;
      _odometerError = _odometerController.text.isEmpty
          ? 'Required'
          : !_isValidNumber(_odometerController.text)
              ? 'Enter a valid number'
              : null;
    });
  }

  bool _isValidNumber(String value) {
    if (value.isEmpty) return false;
    try {
      final number = double.parse(value);
      return number > 0;
    } catch (e) {
      return false;
    }
  }

  Future<void> _save() async {
    _validateFields();
    
    if (_gallonsError != null || _costError != null || _odometerError != null) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Invalid Input'),
          content: const Text('Please fill in all required fields with valid numbers.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    final record = FuelRecord(
      id: widget.record?.id,
      vehicleId: _selectedVehicle.id!,
      date: _date,
      gallons: double.parse(_gallonsController.text),
      cost: double.parse(_costController.text),
      odometer: double.parse(_odometerController.text),
      station: _stationController.text.isNotEmpty ? _stationController.text : null,
      location:
          _locationController.text.isNotEmpty ? _locationController.text : null,
      isPartialFill: _isPartialFill,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    try {
      if (_isEditing) {
        await _fuelService.updateFuelRecord(record);
      } else {
        await _fuelService.addFuelRecord(record);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Error'),
            content: Text('Failed to save fuel record: ${e.toString()}'),
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
  }

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.selectedVehicle ?? widget.vehicles.first;
    _date = DateTime.now();

    if (widget.record != null) {
      _isEditing = true;
      _selectedVehicle = widget.vehicles.firstWhere(
        (v) => v.id == widget.record!.vehicleId,
      );
      _date = widget.record!.date;
      _gallonsController.text = widget.record!.gallons.toString();
      _costController.text = widget.record!.cost.toString();
      _odometerController.text = widget.record!.odometer.toString();
      _stationController.text = widget.record!.station ?? '';
      _locationController.text = widget.record!.location ?? '';
      _notesController.text = widget.record!.notes ?? '';
      _isPartialFill = widget.record!.isPartialFill;
    }
  }

  @override
  void dispose() {
    _gallonsController.dispose();
    _costController.dispose();
    _odometerController.dispose();
    _stationController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested != LocationPermission.whileInUse &&
            requested != LocationPermission.always) {
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final location =
            '${place.street}, ${place.locality}, ${place.administrativeArea}';
        setState(() {
          _locationController.text = location;
        });
      }
    } catch (e) {
      // Handle location error
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isEditing ? 'Edit Fuel Record' : 'Add Fuel Record'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Save'),
          onPressed: _save,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            // Vehicle and Date Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Vehicle selector
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                  _selectedVehicle = widget.vehicles[index];
                                });
                              },
                              children: widget.vehicles
                                  .map((v) => Text('${v.year} ${v.make} ${v.model}'))
                                  .toList(),
                            ),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.car_detailed,
                              color: CupertinoColors.systemGrey,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Vehicle',
                              style: TextStyle(
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${_selectedVehicle.year} ${_selectedVehicle.make} ${_selectedVehicle.model}',
                              style: const TextStyle(color: CupertinoColors.label),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              CupertinoIcons.chevron_right,
                              color: CupertinoColors.systemGrey,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 1,
                    color: CupertinoColors.systemGrey.withOpacity(0.2),
                  ),
                  // Date picker
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    onPressed: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) => Container(
                          height: 216,
                          padding: const EdgeInsets.only(top: 6.0),
                          margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          color: CupertinoColors.systemBackground.resolveFrom(context),
                          child: SafeArea(
                            top: false,
                            child: CupertinoDatePicker(
                              initialDateTime: _date,
                              mode: CupertinoDatePickerMode.date,
                              use24hFormat: true,
                              onDateTimeChanged: (DateTime newDate) {
                                setState(() => _date = newDate);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              CupertinoIcons.calendar,
                              color: CupertinoColors.systemGrey,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Date',
                              style: TextStyle(
                                color: CupertinoColors.systemGrey,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              '${_date.month}/${_date.day}/${_date.year}',
                              style: const TextStyle(color: CupertinoColors.label),
                            ),
                            const SizedBox(width: 5),
                            const Icon(
                              CupertinoIcons.chevron_right,
                              color: CupertinoColors.systemGrey,
                              size: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Fill Details Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Gallons
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CupertinoTextField.borderless(
                              controller: _gallonsController,
                              placeholder: 'Gallons',
                              prefix: const Padding(
                                padding: EdgeInsets.only(left: 0),
                                child: Icon(
                                  CupertinoIcons.drop,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _showErrors && _gallonsError != null
                                        ? CupertinoColors.systemRed
                                        : CupertinoColors.systemGrey.withOpacity(0.2),
                                  ),
                                ),
                              ),
                            ),
                            if (_showErrors && _gallonsError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _gallonsError!,
                                  style: const TextStyle(
                                    color: CupertinoColors.systemRed,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Cost
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CupertinoTextField.borderless(
                              controller: _costController,
                              placeholder: 'Total Cost',
                              prefix: const Padding(
                                padding: EdgeInsets.only(left: 0),
                                child: Icon(
                                  CupertinoIcons.money_dollar,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _showErrors && _costError != null
                                        ? CupertinoColors.systemRed
                                        : CupertinoColors.systemGrey.withOpacity(0.2),
                                  ),
                                ),
                              ),
                            ),
                            if (_showErrors && _costError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _costError!,
                                  style: const TextStyle(
                                    color: CupertinoColors.systemRed,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Odometer
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CupertinoTextField.borderless(
                              controller: _odometerController,
                              placeholder: 'Odometer Reading',
                              prefix: const Padding(
                                padding: EdgeInsets.only(left: 0),
                                child: Icon(
                                  CupertinoIcons.speedometer,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _showErrors && _odometerError != null
                                        ? CupertinoColors.systemRed
                                        : CupertinoColors.systemGrey.withOpacity(0.2),
                                  ),
                                ),
                              ),
                            ),
                            if (_showErrors && _odometerError != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _odometerError!,
                                  style: const TextStyle(
                                    color: CupertinoColors.systemRed,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Additional Details Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Station
                        CupertinoTextField.borderless(
                          controller: _stationController,
                          placeholder: 'Gas Station (optional)',
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 0),
                            child: Icon(
                              CupertinoIcons.building_2_fill,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: CupertinoColors.systemGrey.withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Location
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoTextField.borderless(
                                controller: _locationController,
                                placeholder: 'Location (optional)',
                                prefix: const Padding(
                                  padding: EdgeInsets.only(left: 0),
                                  child: Icon(
                                    CupertinoIcons.location,
                                    color: CupertinoColors.systemGrey,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: CupertinoColors.systemGrey.withOpacity(0.2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Icon(
                                CupertinoIcons.location_fill,
                                color: CupertinoColors.systemBlue,
                              ),
                              onPressed: _getCurrentLocation,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Notes
                        CupertinoTextField.borderless(
                          controller: _notesController,
                          placeholder: 'Notes (optional)',
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 0),
                            child: Icon(
                              CupertinoIcons.text_justify,
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                          maxLines: 3,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: CupertinoColors.systemGrey.withOpacity(0.2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Partial Fill Toggle Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: CupertinoColors.systemBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.drop_fill,
                          color: CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Partial Fill',
                          style: TextStyle(
                            color: CupertinoColors.label,
                          ),
                        ),
                      ],
                    ),
                    CupertinoSwitch(
                      value: _isPartialFill,
                      onChanged: (value) {
                        setState(() {
                          _isPartialFill = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
