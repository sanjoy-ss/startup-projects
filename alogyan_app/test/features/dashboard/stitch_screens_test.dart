import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/dashboard/screens/join_live_class_screen.dart';
import 'package:alogyan_app/features/dashboard/screens/class_details_screen.dart';
import 'package:alogyan_app/features/dashboard/screens/whiteboard_screen.dart';
import 'package:alogyan_app/features/dashboard/screens/fees_overview_screen.dart';
import 'package:alogyan_app/features/dashboard/screens/materials_notes_screen.dart';
import 'package:alogyan_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:alogyan_app/features/dashboard/screens/teacher_home_view.dart';
import 'package:alogyan_app/features/dashboard/screens/executive_dashboard_view.dart';

void main() {
  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  test('Verify all stitch dashboard screens are strictly StatelessWidget', () {
    expect(const DashboardScreen(), isA<StatelessWidget>());
    expect(const TeacherHomeView(), isA<StatelessWidget>());
    expect(const ExecutiveDashboardView(), isA<StatelessWidget>());
    expect(const JoinLiveClassScreen(), isA<StatelessWidget>());
    expect(const ClassDetailsScreen(), isA<StatelessWidget>());
    expect(const WhiteboardScreen(), isA<StatelessWidget>());
    expect(const FeesOverviewScreen(), isA<StatelessWidget>());
    expect(const MaterialsNotesScreen(), isA<StatelessWidget>());
  });

  testWidgets('JoinLiveClassScreen renders meet details and actions', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: JoinLiveClassScreen(),
      ),
    );

    expect(find.text('Join Live Class'), findsOneWidget);
    expect(find.text('Flutter Layouts and Responsive UI'), findsOneWidget);
    expect(find.text('Google Meet HD Video'), findsOneWidget);
    expect(find.text('Start / Join Meeting'), findsOneWidget);
  });

  testWidgets('ClassDetailsScreen renders class overview and roster', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: ClassDetailsScreen(),
      ),
    );

    expect(find.text('Class Details'), findsOneWidget);
    expect(find.text('LIVE SESSION'), findsOneWidget);
    expect(find.text('Session Agenda & Objectives'), findsOneWidget);
    expect(find.text('Enrolled Students (24)'), findsOneWidget);
  });

  testWidgets('WhiteboardScreen renders tools and architecture canvas', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: WhiteboardScreen(),
      ),
    );

    expect(find.text('Flutter Layouts & UI Whiteboard'), findsOneWidget);
    expect(find.text('Auto-saved to Cloud'), findsOneWidget);
    expect(find.text('View Only (Tap to draw)'), findsOneWidget);
  });

  testWidgets('FeesOverviewScreen renders KPI metrics and student filter', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: FeesOverviewScreen(),
      ),
    );

    expect(find.text('Fees Overview'), findsOneWidget);
    expect(find.text('Collected'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
    expect(find.text('Overdue'), findsOneWidget);
  });

  testWidgets('MaterialsNotesScreen renders storage status and materials list', (tester) async {
    await tester.pumpWidget(
      const GetMaterialApp(
        home: MaterialsNotesScreen(),
      ),
    );

    expect(find.text('Materials & Notes'), findsOneWidget);
    expect(find.text('Pinned for Upcoming Class'), findsOneWidget);
    expect(find.text('FILTER BY BATCH'), findsOneWidget);
  });
}
