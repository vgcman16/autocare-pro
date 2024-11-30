import 'package:flutter/cupertino.dart';

class GuidesScreen extends StatelessWidget {
  const GuidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Maintenance Guides'),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            _buildGuideSection('Basic Maintenance'),
            _buildGuideSection('Advanced Repairs'),
            _buildGuideSection('Emergency Procedures'),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideSection(String title) {
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
          children: [
            _buildGuideItem(
              'Oil Change Guide',
              'Step-by-step instructions for changing your car\'s oil',
              CupertinoIcons.wrench_fill,
            ),
            _buildGuideItem(
              'Tire Maintenance',
              'How to check tire pressure and perform rotation',
              CupertinoIcons.circle_grid_hex_fill,
            ),
            _buildGuideItem(
              'Battery Care',
              'Tips for maintaining and testing your car battery',
              CupertinoIcons.bolt_fill,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGuideItem(String title, String description, IconData icon) {
    return CupertinoListTile(
      title: Text(title),
      subtitle: Text(
        description,
        style: const TextStyle(
          fontSize: 12,
          color: CupertinoColors.systemGrey,
        ),
      ),
      leading: Icon(
        icon,
        color: CupertinoColors.systemBlue,
      ),
      trailing: const CupertinoListTileChevron(),
    );
  }
}
