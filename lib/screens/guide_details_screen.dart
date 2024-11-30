import 'package:flutter/cupertino.dart';
import '../models/maintenance_guide.dart';

class GuideDetailsScreen extends StatelessWidget {
  final MaintenanceGuide guide;

  const GuideDetailsScreen({
    super.key,
    required this.guide,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Guide Details'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildDescription(),
            const SizedBox(height: 20),
            _buildSteps(),
            const SizedBox(height: 20),
            _buildTools(),
            const SizedBox(height: 20),
            _buildParts(),
            if (guide.videoUrl != null) ...[
              const SizedBox(height: 20),
              _buildVideo(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return CupertinoListSection.insetGrouped(
      header: const Text('Overview'),
      children: [
        CupertinoListTile(
          title: Text(
            guide.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CupertinoListTile(
          title: const Text('Difficulty'),
          trailing: Text(
            guide.difficulty,
            style: TextStyle(
              color: guide.difficulty == 'Easy'
                  ? CupertinoColors.systemGreen
                  : guide.difficulty == 'Medium'
                      ? CupertinoColors.systemYellow
                      : CupertinoColors.systemRed,
            ),
          ),
        ),
        CupertinoListTile(
          title: const Text('Estimated Time'),
          trailing: Text('${guide.estimatedDuration} mins'),
        ),
        CupertinoListTile(
          title: const Text('Estimated Cost'),
          trailing: Text('\$${guide.estimatedCost.toStringAsFixed(2)}'),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return CupertinoListSection.insetGrouped(
      header: const Text('Description'),
      children: [
        CupertinoListTile(
          title: Text(guide.description),
        ),
      ],
    );
  }

  Widget _buildSteps() {
    return CupertinoListSection.insetGrouped(
      header: const Text('Steps'),
      children: [
        for (int i = 0; i < guide.steps.length; i++)
          CupertinoListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(
                color: CupertinoColors.systemBlue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${i + 1}',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(guide.steps[i]),
          ),
      ],
    );
  }

  Widget _buildTools() {
    return CupertinoListSection.insetGrouped(
      header: const Text('Required Tools'),
      children: [
        for (String tool in guide.tools)
          CupertinoListTile(
            leading: const Icon(
              CupertinoIcons.wrench_fill,
              color: CupertinoColors.systemGrey,
            ),
            title: Text(tool),
          ),
      ],
    );
  }

  Widget _buildParts() {
    return CupertinoListSection.insetGrouped(
      header: const Text('Required Parts'),
      children: [
        for (String part in guide.parts)
          CupertinoListTile(
            leading: const Icon(
              CupertinoIcons.cube_fill,
              color: CupertinoColors.systemGrey,
            ),
            title: Text(part),
          ),
      ],
    );
  }

  Widget _buildVideo() {
    return CupertinoListSection.insetGrouped(
      header: const Text('Tutorial Video'),
      children: [
        CupertinoListTile(
          title: const Text('Watch Video'),
          trailing: const CupertinoListTileChevron(),
          onTap: () {
            // TODO: Implement video playback
          },
        ),
      ],
    );
  }
}
