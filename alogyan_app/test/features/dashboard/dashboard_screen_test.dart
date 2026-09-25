import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/features/dashboard/screens/dashboard_screen.dart';

void main() {
  testWidgets('Dashboard renders todays classes and quick action cards', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    expect(find.text("Today's Schedule"), findsOneWidget);
    expect(find.text('Take Attendance'), findsOneWidget);
    expect(find.text('Collect Fee'), findsOneWidget);
  });
}
