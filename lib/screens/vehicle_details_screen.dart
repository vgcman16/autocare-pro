import 'package:flutter/cupertino.dart';
import '../models/vehicle.dart';

class VehicleDetailsScreen extends StatelessWidget {
  final Vehicle vehicle;

  const VehicleDetailsScreen({
    super.key,
    required this.vehicle,
  });

  void _showDeleteConfirmation(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext dialogContext) => CupertinoAlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
          'Are you sure you want to delete ${vehicle.year} ${vehicle.make} ${vehicle.model}? This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              // First pop the dialog
              Navigator.pop(dialogContext);
              // Then return to the vehicle list with delete result
              Navigator.of(context).pop(true);
            },
            child: const Text('Delete'),
          ),
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(dialogContext);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Vehicle Details'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(
            CupertinoIcons.delete,
            color: CupertinoColors.destructiveRed,
          ),
          onPressed: () => _showDeleteConfirmation(context),
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            _buildBasicInfo(),
            const SizedBox(height: 20),
            _buildServiceHistory(),
            const SizedBox(height: 20),
            _buildExpenses(),
            const SizedBox(height: 20),
            _buildDocuments(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return CupertinoListSection.insetGrouped(
      header: const Text('Basic Information'),
      children: [
        CupertinoListTile(
          title: const Text('Make'),
          trailing: Text(vehicle.make),
        ),
        CupertinoListTile(
          title: const Text('Model'),
          trailing: Text(vehicle.model),
        ),
        CupertinoListTile(
          title: const Text('Year'),
          trailing: Text(vehicle.year.toString()),
        ),
        CupertinoListTile(
          title: const Text('VIN'),
          trailing: Text(vehicle.vin),
        ),
        CupertinoListTile(
          title: const Text('Current Mileage'),
          trailing: Text('${vehicle.mileage} miles'),
        ),
      ],
    );
  }

  Widget _buildServiceHistory() {
    return CupertinoListSection.insetGrouped(
      header: const Text('Service History'),
      children: [
        CupertinoListTile(
          title: const Text('Last Oil Change'),
          subtitle: const Text('3,000 miles ago'),
          trailing: const CupertinoListTileChevron(),
        ),
        CupertinoListTile(
          title: const Text('Last Tire Rotation'),
          subtitle: const Text('5,000 miles ago'),
          trailing: const CupertinoListTileChevron(),
        ),
      ],
    );
  }

  Widget _buildExpenses() {
    return CupertinoListSection.insetGrouped(
      header: const Text('Expenses'),
      children: [
        const CupertinoListTile(
          title: Text('Total Expenses (2024)'),
          trailing: Text('\$1,250.00'),
        ),
        CupertinoListTile(
          title: const Text('View All Expenses'),
          trailing: const CupertinoListTileChevron(),
          onTap: () {
            // TODO: Navigate to expenses filtered by vehicle
          },
        ),
      ],
    );
  }

  Widget _buildDocuments() {
    return CupertinoListSection.insetGrouped(
      header: const Text('Documents'),
      children: [
        CupertinoListTile(
          title: const Text('Registration'),
          subtitle: const Text('Expires: Dec 31, 2024'),
          trailing: const CupertinoListTileChevron(),
        ),
        CupertinoListTile(
          title: const Text('Insurance'),
          subtitle: const Text('Expires: Jun 30, 2024'),
          trailing: const CupertinoListTileChevron(),
        ),
      ],
    );
  }
}
