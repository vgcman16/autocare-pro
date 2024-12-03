import 'package:flutter/cupertino.dart';
import '../models/maintenance_task.dart';
import '../models/vehicle.dart';
import 'package:intl/intl.dart';

class AddMaintenanceTaskScreen extends StatefulWidget {
  final List<Vehicle> vehicles;

  const AddMaintenanceTaskScreen({
    super.key,
    required this.vehicles,
  });

  @override
  State<AddMaintenanceTaskScreen> createState() => _AddMaintenanceTaskScreenState();
}

class _AddMaintenanceTaskScreenState extends State<AddMaintenanceTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late Vehicle? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.vehicles.isNotEmpty ? widget.vehicles.first : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _mileageController.dispose();
    _notesController.dispose();
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
            initialDateTime: _selectedDate,
            mode: CupertinoDatePickerMode.date,
            use24hFormat: true,
            onDateTimeChanged: (DateTime newDate) {
              setState(() => _selectedDate = newDate);
            },
          ),
        ),
      ),
    );
  }

  void _saveTask() {
    if (_titleController.text.isEmpty || _mileageController.text.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Missing Information'),
          content: const Text('Please fill in all required fields'),
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

    final task = MaintenanceTask(
      title: _titleController.text,
      dueDate: _selectedDate,
      dueMileage: int.parse(_mileageController.text),
      notes: _notesController.text,
      vehicleId: _selectedVehicle?.id ?? 0,
    );

    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.vehicles.isEmpty) {
      return CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          middle: Text('Add Maintenance Task'),
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
        middle: const Text('Add Maintenance Task'),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Save'),
          onPressed: _saveTask,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('Task Details'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _titleController,
                  prefix: const Text('Title'),
                  placeholder: 'Enter task title',
                  autocorrect: false,
                ),
                CupertinoTextFormFieldRow(
                  controller: _mileageController,
                  prefix: const Text('Due Mileage'),
                  placeholder: 'Enter mileage',
                  keyboardType: TextInputType.number,
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _showDatePicker,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 16.0),
                        const Text(
                          'Due Date',
                          style: TextStyle(
                            color: CupertinoColors.label,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('MMM d, yyyy').format(_selectedDate),
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              header: const Text('Vehicle'),
              children: [
                CupertinoButton(
                  padding: EdgeInsets.zero,
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
                          child: CupertinoPicker(
                            itemExtent: 32.0,
                            onSelectedItemChanged: (int index) {
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
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        const SizedBox(width: 16.0),
                        const Text(
                          'Vehicle',
                          style: TextStyle(
                            color: CupertinoColors.label,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_selectedVehicle?.year} ${_selectedVehicle?.make} ${_selectedVehicle?.model}',
                          style: const TextStyle(
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            CupertinoListSection.insetGrouped(
              header: const Text('Additional Information'),
              children: [
                CupertinoTextFormFieldRow(
                  controller: _notesController,
                  prefix: const Text('Notes'),
                  placeholder: 'Enter any additional notes',
                  maxLines: 3,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
