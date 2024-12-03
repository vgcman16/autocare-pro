import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/vehicle.dart';
import '../models/maintenance_reminder.dart';
import '../services/maintenance_reminder_service.dart';

class AddReminderScreen extends StatefulWidget {
  final List<Vehicle> vehicles;
  final MaintenanceReminder? reminder; // For editing existing reminders

  const AddReminderScreen({
    super.key,
    required this.vehicles,
    this.reminder,
  });

  @override
  State<AddReminderScreen> createState() => _AddReminderScreenState();
}

class _AddReminderScreenState extends State<AddReminderScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mileageController = TextEditingController();
  final _repeatMilesController = TextEditingController();
  final _reminderService = MaintenanceReminderService();

  late Vehicle? _selectedVehicle;
  late DateTime _dueDate;
  String _frequency = 'once';
  bool _isEditing = false;

  final List<String> _frequencies = [
    'once',
    'monthly',
    'yearly',
    'mileage',
  ];

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.vehicles.isNotEmpty ? widget.vehicles.first : null;
    _dueDate = DateTime.now().add(const Duration(days: 7));

    if (widget.reminder != null) {
      _isEditing = true;
      _titleController.text = widget.reminder!.title;
      _descriptionController.text = widget.reminder!.description;
      _dueDate = widget.reminder!.dueDate;
      _frequency = widget.reminder!.frequency;
      if (widget.reminder!.dueMileage != null) {
        _mileageController.text = widget.reminder!.dueMileage.toString();
      }
      if (widget.reminder!.repeatMiles != null) {
        _repeatMilesController.text = widget.reminder!.repeatMiles.toString();
      }
      _selectedVehicle = widget.vehicles.firstWhere(
        (v) => v.id == widget.reminder!.vehicleId,
        orElse: () => widget.vehicles.first,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _mileageController.dispose();
    _repeatMilesController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
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
            initialDateTime: _dueDate,
            mode: CupertinoDatePickerMode.date,
            use24hFormat: true,
            onDateTimeChanged: (DateTime newDate) {
              setState(() => _dueDate = newDate);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _saveReminder() async {
    if (_selectedVehicle == null) {
      // Show error
      return;
    }

    final reminder = MaintenanceReminder(
      id: widget.reminder?.id,
      vehicleId: _selectedVehicle!.id!,
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _dueDate,
      dueMileage: _mileageController.text.isNotEmpty
          ? int.parse(_mileageController.text)
          : null,
      frequency: _frequency,
      repeatMiles: _repeatMilesController.text.isNotEmpty
          ? int.parse(_repeatMilesController.text)
          : null,
    );

    if (_isEditing) {
      await _reminderService.updateReminder(reminder);
    } else {
      await _reminderService.addReminder(reminder);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.vehicles.isEmpty) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Add Reminder'),
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
                CupertinoButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_isEditing ? 'Edit Reminder' : 'Add Reminder'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Save'),
          onPressed: _saveReminder,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CupertinoTextField(
              controller: _titleController,
              placeholder: 'Title',
              padding: const EdgeInsets.all(12),
            ),
            const SizedBox(height: 16),
            CupertinoTextField(
              controller: _descriptionController,
              placeholder: 'Description',
              padding: const EdgeInsets.all(12),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _showDatePicker,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: CupertinoColors.systemGrey.withOpacity(0.2),
                  ),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Due Date'),
                    Text(
                      DateFormat('MMM d, y').format(_dueDate),
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: CupertinoColors.systemGrey.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Vehicle'),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      _selectedVehicle != null
                          ? '${_selectedVehicle!.year} ${_selectedVehicle!.make} ${_selectedVehicle!.model}'
                          : 'Select Vehicle',
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
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
                          color:
                              CupertinoColors.systemBackground.resolveFrom(context),
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
                                  .map((v) => Text(
                                      '${v.year} ${v.make} ${v.model}'))
                                  .toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: CupertinoColors.systemGrey.withOpacity(0.2),
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Frequency'),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: Text(
                      _frequency,
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey,
                      ),
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
                          color:
                              CupertinoColors.systemBackground.resolveFrom(context),
                          child: SafeArea(
                            top: false,
                            child: CupertinoPicker(
                              itemExtent: 32,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _frequency = _frequencies[index];
                                });
                              },
                              children:
                                  _frequencies.map((f) => Text(f)).toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (_frequency == 'mileage') ...[
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _mileageController,
                placeholder: 'Due at Mileage',
                padding: const EdgeInsets.all(12),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              CupertinoTextField(
                controller: _repeatMilesController,
                placeholder: 'Repeat Every (miles)',
                padding: const EdgeInsets.all(12),
                keyboardType: TextInputType.number,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
