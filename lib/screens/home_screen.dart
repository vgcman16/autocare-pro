import 'package:flutter/cupertino.dart';
import 'vehicle_list_screen.dart';
import 'maintenance_screen.dart';
import 'expenses_screen.dart';
import 'guides_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.car_detailed),
            label: 'Vehicles',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.wrench),
            label: 'Maintenance',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.money_dollar),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.book),
            label: 'Guides',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        return CupertinoTabView(
          builder: (context) {
            switch (index) {
              case 0:
                return const VehicleListScreen();
              case 1:
                return const MaintenanceScreen();
              case 2:
                return const ExpensesScreen();
              case 3:
                return const GuidesScreen();
              case 4:
                return const SettingsScreen();
              default:
                return const VehicleListScreen();
            }
          },
        );
      },
    );
  }
}
