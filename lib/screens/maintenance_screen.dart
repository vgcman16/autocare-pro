import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../models/maintenance_task.dart';
import '../models/maintenance_guide.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import 'add_maintenance_task_screen.dart';
import 'add_guide_screen.dart';
import 'guide_details_screen.dart';
import 'reminders_screen.dart';

class MaintenanceScreen extends StatefulWidget {
  final int vehicleId;

  const MaintenanceScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  int _selectedSegment = 0;
  final List<MaintenanceTask> _upcomingTasks = [];
  final List<MaintenanceTask> _recentTasks = [];
  final List<MaintenanceGuide> _guides = [
    MaintenanceGuide(
      title: 'Oil Change Guide',
      description: 'Step-by-step guide for changing your vehicle\'s oil',
      steps: [
        'Park on level ground and engage parking brake',
        'Warm up engine for 2-3 minutes',
        'Locate drain plug and oil filter',
        'Drain old oil',
        'Replace oil filter',
        'Add new oil',
        'Check oil level',
      ],
      estimatedDuration: 30,
      estimatedCost: 35.00,
      difficulty: 'Easy',
      tools: ['Oil filter wrench', 'Socket set', 'Oil pan', 'Funnel'],
      parts: ['Oil filter', '5 quarts of oil'],
    ),
    MaintenanceGuide(
      title: 'Tire Rotation',
      description: 'How to properly rotate your tires',
      steps: [
        'Engage parking brake',
        'Loosen lug nuts',
        'Jack up vehicle',
        'Remove wheels',
        'Rotate according to pattern',
        'Torque lug nuts to spec',
      ],
      estimatedDuration: 45,
      estimatedCost: 20.00,
      difficulty: 'Easy',
      tools: ['Jack', 'Jack stands', 'Lug wrench', 'Torque wrench'],
      parts: [],
    ),
  ];
  final List<Vehicle> _vehicles = [];
  final VehicleService _vehicleService = VehicleService();

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final vehicles = await _vehicleService.getVehicles();
      setState(() {
        _vehicles.clear();
        _vehicles.addAll(vehicles);
      });
    } catch (e) {
      // TODO: Show error to user
      print('Error loading vehicles: $e');
    }
  }

  void _addMaintenanceTask() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AddMaintenanceTaskScreen(
          vehicles: _vehicles,
        ),
      ),
    );

    if (result != null && result is MaintenanceTask) {
      setState(() {
        _upcomingTasks.add(result);
      });
    }
  }

  void _addGuide() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const AddGuideScreen(),
      ),
    );

    if (result != null && result is MaintenanceGuide) {
      setState(() {
        _guides.add(result);
      });
    }
  }

  void _viewGuideDetails(MaintenanceGuide guide) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => GuideDetailsScreen(guide: guide),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: CupertinoSegmentedControl<int>(
          children: const {
            0: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Tasks'),
            ),
            1: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Reminders'),
            ),
            2: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Guides'),
            ),
          },
          groupValue: _selectedSegment,
          onValueChanged: (int value) {
            setState(() {
              _selectedSegment = value;
            });
          },
        ),
      ),
      child: SafeArea(
        child: IndexedStack(
          index: _selectedSegment,
          children: [
            _buildTasksTab(),
            const RemindersScreen(),
            _buildGuidesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksTab() {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Upcoming Tasks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_upcomingTasks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No upcoming tasks'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _upcomingTasks.length,
            itemBuilder: (context, index) {
              return _buildTaskItem(_upcomingTasks[index]);
            },
          ),
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Recent Tasks',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_recentTasks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No recent tasks'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentTasks.length,
            itemBuilder: (context, index) {
              return _buildTaskItem(_recentTasks[index]);
            },
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CupertinoButton.filled(
            onPressed: _addMaintenanceTask,
            child: const Text('Add Task'),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(MaintenanceTask task) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(task.notes),
            const SizedBox(height: 8),
            Text('Due Date: ${DateFormat('MMM d, y').format(task.dueDate)}'),
            Text('Due Mileage: ${task.dueMileage} miles'),
            if (task.isCompleted) const Text('Status: Completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidesTab() {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CupertinoSearchTextField(
            onChanged: (String value) {
              // Implement search functionality
            },
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _guides.length,
          itemBuilder: (context, index) {
            final guide = _guides[index];
            return CupertinoListTile(
              title: Text(guide.title),
              subtitle: Text(guide.description),
              trailing: const CupertinoListTileChevron(),
              onTap: () {
                _viewGuideDetails(guide);
              },
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: CupertinoButton.filled(
            onPressed: _addGuide,
            child: const Text('Add Guide'),
          ),
        ),
      ],
    );
  }
}
