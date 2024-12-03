import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/maintenance_reminder.dart';
import '../models/vehicle.dart';
import '../services/maintenance_reminder_service.dart';
import '../services/vehicle_service.dart';
import 'add_reminder_screen.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final _reminderService = MaintenanceReminderService();
  final _vehicleService = VehicleService();
  List<MaintenanceReminder> _reminders = [];
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final vehicles = await _vehicleService.getVehicles();
    final reminders = await _reminderService.getReminders(
      vehicleId: _selectedVehicle?.id,
    );

    setState(() {
      _vehicles = vehicles;
      _reminders = reminders;
    });
  }

  Future<void> _addReminder() async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AddReminderScreen(vehicles: _vehicles),
      ),
    );
    _loadData();
  }

  Future<void> _editReminder(MaintenanceReminder reminder) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AddReminderScreen(
          vehicles: _vehicles,
          reminder: reminder,
        ),
      ),
    );
    _loadData();
  }

  Future<void> _deleteReminder(MaintenanceReminder reminder) async {
    await _reminderService.deleteReminder(reminder.id!);
    _loadData();
  }

  Future<void> _toggleComplete(MaintenanceReminder reminder) async {
    final updatedReminder = reminder.copyWith(
      isCompleted: !reminder.isCompleted,
    );
    await _reminderService.updateReminder(updatedReminder);
    _loadData();
  }

  Widget _buildReminderItem(MaintenanceReminder reminder) {
    final vehicle = _vehicles.firstWhere(
      (v) => v.id == reminder.vehicleId,
      orElse: () => Vehicle(make: 'Unknown', model: 'Vehicle', year: 0, mileage: 0),
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(
          color: CupertinoColors.systemGrey.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CupertinoListTile(
        title: Text(
          reminder.title,
          style: TextStyle(
            decoration: reminder.isCompleted
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${vehicle.year} ${vehicle.make} ${vehicle.model}'),
            Text('Due: ${DateFormat('MMM d, y').format(reminder.dueDate)}'),
            if (reminder.dueMileage != null)
              Text('Due at: ${reminder.dueMileage} miles'),
            if (reminder.description.isNotEmpty)
              Text(
                reminder.description,
                style: const TextStyle(
                  color: CupertinoColors.systemGrey,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: Icon(
                reminder.isCompleted
                    ? CupertinoIcons.check_mark_circled_solid
                    : CupertinoIcons.circle,
                color: reminder.isCompleted
                    ? CupertinoColors.activeGreen
                    : CupertinoColors.systemGrey,
              ),
              onPressed: () => _toggleComplete(reminder),
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(
                CupertinoIcons.ellipsis,
                color: CupertinoColors.systemGrey,
              ),
              onPressed: () {
                showCupertinoModalPopup(
                  context: context,
                  builder: (context) => CupertinoActionSheet(
                    actions: [
                      CupertinoActionSheetAction(
                        child: const Text('Edit'),
                        onPressed: () {
                          Navigator.pop(context);
                          _editReminder(reminder);
                        },
                      ),
                      CupertinoActionSheetAction(
                        isDestructiveAction: true,
                        child: const Text('Delete'),
                        onPressed: () {
                          Navigator.pop(context);
                          _deleteReminder(reminder);
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
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Maintenance Reminders'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: _vehicles.isEmpty ? null : _addReminder,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_vehicles.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('Filter by Vehicle: '),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        _selectedVehicle != null
                            ? '${_selectedVehicle!.year} ${_selectedVehicle!.make} ${_selectedVehicle!.model}'
                            : 'All Vehicles',
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
                            color: CupertinoColors.systemBackground
                                .resolveFrom(context),
                            child: SafeArea(
                              top: false,
                              child: CupertinoPicker(
                                itemExtent: 32,
                                onSelectedItemChanged: (index) {
                                  setState(() {
                                    _selectedVehicle = index == 0
                                        ? null
                                        : _vehicles[index - 1];
                                  });
                                  _loadData();
                                },
                                children: [
                                  const Text('All Vehicles'),
                                  ..._vehicles.map(
                                    (v) => Text(
                                        '${v.year} ${v.make} ${v.model}'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            Expanded(
              child: _vehicles.isEmpty
                  ? Center(
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
                    )
                  : _reminders.isEmpty
                      ? const Center(
                          child: Text('No reminders found'),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _reminders.length,
                          itemBuilder: (context, index) =>
                              _buildReminderItem(_reminders[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
