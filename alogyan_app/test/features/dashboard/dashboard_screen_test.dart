import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/dashboard/screens/dashboard_screen.dart';

void main() {
  testWidgets('Dashboard renders Stitch teacher home and executive vitals', (tester) async {
    Get.testMode = true;
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DashboardScreen(),
        ),
      ),
    );

    // Verify Stitch switcher & teacher home elements
    expect(find.text('Teacher Home'), findsWidgets);
    expect(find.text('Executive Vitals'), findsOneWidget);
    expect(find.text("Today's Classes"), findsOneWidget);
    expect(find.text('Mark Attendance'), findsWidgets);
    expect(find.text('Record Fee'), findsOneWidget);

    // Toggle to Executive Vitals
    await tester.tap(find.text('Executive Vitals'));
    await tester.pumpAndSettle();

    expect(find.text('Agartala Campus'), findsOneWidget);
    expect(find.text('Campus Vitals'), findsOneWidget);
    expect(find.text('Weekly Attendance Trend'), findsOneWidget);
  });
}
