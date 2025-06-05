// Basic widget test for AutoCare Pro
// Verifies that the home screen loads with a navigation bar and the
// "Vehicles" destination is present.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:car_maintenance_tracker/main.dart';

void main() {
  testWidgets('Home screen shows navigation bar', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const CarMaintenanceApp());
    await tester.pumpAndSettle();

    // Verify the navigation bar and first destination.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(
      find.widgetWithText(NavigationDestination, 'Vehicles'),
      findsOneWidget,
    );
  });
}
