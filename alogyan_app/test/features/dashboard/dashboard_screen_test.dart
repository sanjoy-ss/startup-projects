import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/dashboard/screens/dashboard_screen.dart';

void main() {
  testWidgets('Dashboard renders todays classes and quick action cards', (tester) async {
    Get.testMode = true;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DashboardScreen(),
        ),
      ),
    );

    expect(find.text("Today's Schedule"), findsOneWidget);
    expect(find.text('Take Attendance'), findsOneWidget);
    expect(find.text('Collect Fee'), findsOneWidget);
  });
}
