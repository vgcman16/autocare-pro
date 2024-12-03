import 'package:flutter/cupertino.dart';
import '../models/vehicle.dart';
import '../services/car_api_service.dart';
import '../services/vehicle_service.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _vinController = TextEditingController();
  final _mileageController = TextEditingController();
  final _carApiService = CarApiService();
  final _vehicleService = VehicleService();
  
  List<String> _makes = [];
  List<String> _models = [];
  bool _isLoadingMakes = false;
  bool _isLoadingModels = false;
  String? _selectedMake;
  int? _selectedYear;
  bool _isSaving = false;

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  Future<void> _loadMakes(int year) async {
    setState(() {
      _isLoadingMakes = true;
      _makes = [];
      _selectedMake = null;
    });

    try {
      if (year < 1995 || year > DateTime.now().year + 1) {
        throw Exception('Please enter a year between 1995 and ${DateTime.now().year + 1}');
      }
      final makes = await _carApiService.getMakes(year: year);
      setState(() {
        _makes = makes;
        _isLoadingMakes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMakes = false;
      });
      _showError(e.toString());
    }
  }

  Future<void> _loadModels(String make, int year) async {
    setState(() {
      _isLoadingModels = true;
      _models = [];
    });

    try {
      final models = await _carApiService.getModels(make: make, year: year);
      setState(() {
        _models = models;
        _isLoadingModels = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingModels = false;
      });
      _showError(e.toString());
    }
  }

  Future<void> _lookupVin(String vin) async {
    try {
      final vehicle = await _carApiService.decodeVin(vin);
      setState(() {
        _yearController.text = vehicle.year.toString();
        _makeController.text = vehicle.make;
        _modelController.text = vehicle.model;
        _selectedYear = vehicle.year;
        _selectedMake = vehicle.make;
      });
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Future<void> _saveVehicle() async {
    if (_makeController.text.isEmpty ||
        _modelController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _mileageController.text.isEmpty) {
      _showError('Please fill in all required fields');
      return;
    }

    final year = int.tryParse(_yearController.text);
    final mileage = int.tryParse(_mileageController.text);

    if (year == null) {
      _showError('Please enter a valid year');
      return;
    }

    if (mileage == null) {
      _showError('Please enter a valid mileage');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final vehicle = Vehicle(
        make: _makeController.text,
        model: _modelController.text,
        year: year,
        mileage: mileage,
        vin: _vinController.text.isNotEmpty ? _vinController.text : null,
      );

      final savedVehicle = await _vehicleService.addVehicle(vehicle);
      if (!mounted) return;
      
      Navigator.pop(context, savedVehicle);
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to save vehicle: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Add Vehicle'),
        trailing: _isSaving
            ? const CupertinoActivityIndicator()
            : CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Save'),
                onPressed: _saveVehicle,
              ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoFormSection.insetGrouped(
              header: const Text('VEHICLE INFORMATION'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _yearController,
                  prefix: const Text('Year*'),
                  placeholder: 'Enter year',
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.length == 4) {
                      final year = int.tryParse(value);
                      if (year != null) {
                        _selectedYear = year;
                        _loadMakes(year);
                      }
                    }
                  },
                ),
                CupertinoTextFormFieldRow(
                  controller: _makeController,
                  prefix: const Text('Make*'),
                  placeholder: _isLoadingMakes ? 'Loading...' : 'Enter make',
                  readOnly: _makes.isNotEmpty,
                  onTap: () {
                    if (_makes.isNotEmpty) {
                      _showMakePicker();
                    }
                  },
                ),
                CupertinoTextFormFieldRow(
                  controller: _modelController,
                  prefix: const Text('Model*'),
                  placeholder: _isLoadingModels ? 'Loading...' : 'Enter model',
                  readOnly: _models.isNotEmpty,
                  onTap: () {
                    if (_models.isNotEmpty) {
                      _showModelPicker();
                    }
                  },
                ),
                CupertinoTextFormFieldRow(
                  controller: _mileageController,
                  prefix: const Text('Mileage*'),
                  placeholder: 'Enter current mileage',
                  keyboardType: TextInputType.number,
                ),
                CupertinoTextFormFieldRow(
                  controller: _vinController,
                  prefix: const Text('VIN'),
                  placeholder: 'Enter VIN (optional)',
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (value) {
                    if (value.length == 17) {
                      _lookupVin(value);
                    }
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '* Required fields',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMakePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: CupertinoButton(
                child: const Text('Done'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _selectedMake = _makes[index];
                    _makeController.text = _makes[index];
                    if (_selectedYear != null) {
                      _loadModels(_makes[index], _selectedYear!);
                    }
                  });
                },
                children: _makes.map((make) => Text(make)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showModelPicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CupertinoColors.systemBackground,
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: CupertinoButton(
                child: const Text('Done'),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 32.0,
                onSelectedItemChanged: (index) {
                  setState(() {
                    _modelController.text = _models[index];
                  });
                },
                children: _models.map((model) => Text(model)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
