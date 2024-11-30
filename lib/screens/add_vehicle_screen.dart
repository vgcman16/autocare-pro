import 'package:flutter/cupertino.dart';
import '../models/vehicle.dart';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _vinController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _vinController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _saveVehicle() {
    if (_makeController.text.isEmpty ||
        _modelController.text.isEmpty ||
        _yearController.text.isEmpty ||
        _vinController.text.isEmpty ||
        _mileageController.text.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Missing Information'),
          content: const Text('Please fill in all fields'),
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

    final vehicle = Vehicle(
      make: _makeController.text,
      model: _modelController.text,
      year: int.parse(_yearController.text),
      vin: _vinController.text,
      mileage: int.parse(_mileageController.text),
    );

    Navigator.pop(context, vehicle);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Add Vehicle'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Save'),
          onPressed: _saveVehicle,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            CupertinoListSection.insetGrouped(
              children: [
                CupertinoTextFormFieldRow(
                  controller: _makeController,
                  prefix: const Text('Make'),
                  placeholder: 'Enter vehicle make',
                  autocorrect: false,
                ),
                CupertinoTextFormFieldRow(
                  controller: _modelController,
                  prefix: const Text('Model'),
                  placeholder: 'Enter vehicle model',
                  autocorrect: false,
                ),
                CupertinoTextFormFieldRow(
                  controller: _yearController,
                  prefix: const Text('Year'),
                  placeholder: 'Enter vehicle year',
                  keyboardType: TextInputType.number,
                ),
                CupertinoTextFormFieldRow(
                  controller: _vinController,
                  prefix: const Text('VIN'),
                  placeholder: 'Enter vehicle VIN',
                  autocorrect: false,
                  textCapitalization: TextCapitalization.characters,
                ),
                CupertinoTextFormFieldRow(
                  controller: _mileageController,
                  prefix: const Text('Mileage'),
                  placeholder: 'Enter current mileage',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
