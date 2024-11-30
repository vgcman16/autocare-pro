import 'package:flutter/cupertino.dart';
import '../models/maintenance_task.dart';
import '../models/maintenance_guide.dart';
import '../models/vehicle.dart';
import 'add_maintenance_task_screen.dart';
import 'add_guide_screen.dart';
import 'guide_details_screen.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
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
      difficulty: 'Medium',
      tools: ['Jack', 'Jack stands', 'Lug wrench', 'Torque wrench'],
      parts: [],
    ),
  ];
  final List<Vehicle> _dummyVehicles = [
    Vehicle(
      make: 'Toyota',
      model: 'Camry',
      year: 2020,
      vin: 'ABC123',
      mileage: 50000,
    ),
  ];
  int _selectedIndex = 0;

  void _addMaintenanceTask() async {
    final result = await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AddMaintenanceTaskScreen(
          vehicles: _dummyVehicles,
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
        middle: const Text('Maintenance'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.add),
          onPressed: _addMaintenanceTask,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            CupertinoSegmentedControl<int>(
              children: const {
                0: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Tasks'),
                ),
                1: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text('Guides'),
                ),
              },
              onValueChanged: (int value) {
                setState(() {
                  _selectedIndex = value;
                });
              },
              groupValue: _selectedIndex,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _selectedIndex == 0
                  ? ListView(
                      children: [
                        _buildMaintenanceSection('Upcoming Maintenance', _upcomingTasks),
                        _buildMaintenanceSection('Recent Maintenance', _recentTasks),
                      ],
                    )
                  : _buildGuidesSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaintenanceSection(String title, List<MaintenanceTask> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CupertinoListSection.insetGrouped(
          children: tasks.isEmpty
              ? [
                  const CupertinoListTile(
                    title: Text('No maintenance tasks'),
                    subtitle: Text('Tap + to add a new task'),
                  ),
                ]
              : tasks.map((task) {
                  final daysUntilDue =
                      task.dueDate.difference(DateTime.now()).inDays;
                  final status = daysUntilDue <= 7
                      ? CupertinoColors.systemRed
                      : daysUntilDue <= 30
                          ? CupertinoColors.systemYellow
                          : CupertinoColors.systemGreen;

                  return CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // TODO: Implement maintenance item tap
                    },
                    child: Container(
                      color: CupertinoColors.systemBackground,
                      child: CupertinoListTile(
                        title: Text(task.title),
                        subtitle: Text('Due in $daysUntilDue days'),
                        leading: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: status,
                            shape: BoxShape.circle,
                          ),
                        ),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                      ),
                    ),
                  );
                }).toList(),
        ),
      ],
    );
  }

  Widget _buildGuidesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Maintenance Guides',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Add Guide'),
                onPressed: _addGuide,
              ),
            ],
          ),
        ),
        CupertinoListSection.insetGrouped(
          children: _guides.isEmpty
              ? [
                  const CupertinoListTile(
                    title: Text('No guides available'),
                    subtitle: Text('Tap Add Guide to create one'),
                  ),
                ]
              : _guides.map((guide) => CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _viewGuideDetails(guide),
                    child: Container(
                      color: CupertinoColors.systemBackground,
                      child: CupertinoListTile(
                        title: Text(guide.title),
                        subtitle: Text(
                          '${guide.difficulty} • ${guide.estimatedDuration} mins • \$${guide.estimatedCost.toStringAsFixed(2)}',
                        ),
                        trailing: const Icon(CupertinoIcons.chevron_right),
                      ),
                    ),
                  )).toList(),
        ),
      ],
    );
  }

  Widget _buildMaintenanceItem(String title, String subtitle, Color color) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        // TODO: Implement maintenance item tap
      },
      child: Container(
        color: CupertinoColors.systemBackground,
        child: CupertinoListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          leading: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          trailing: const Icon(CupertinoIcons.chevron_right),
        ),
      ),
    );
  }
}
