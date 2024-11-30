import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: CupertinoListSection.insetGrouped(
          children: [
            CupertinoListTile(
              title: const Text('Privacy Policy'),
              trailing: const CupertinoListTileChevron(),
              onTap: () => _launchURL('https://github.com/vgcman16/autocare-pro/blob/main/PRIVACY.md'),
            ),
            CupertinoListTile(
              title: const Text('Version'),
              trailing: const Text('1.0.0'),
            ),
            CupertinoListTile(
              title: const Text('About'),
              trailing: const CupertinoListTileChevron(),
              onTap: () => _launchURL('https://github.com/vgcman16/autocare-pro'),
            ),
          ],
        ),
      ),
    );
  }
}
