import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/batches/controllers/batches_controller.dart';
import 'package:alogyan_app/features/batches/models/batch_model.dart';
import 'package:alogyan_app/features/batches/screens/batches_screen.dart';
import 'package:alogyan_app/shared/widgets/status_badge.dart';

void main() {
  group('BatchesController State & Filtering Tests', () {
    late BatchesController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(BatchesController());
      controller.allBatches.assignAll([
        BatchItem(
          id: 'b1',
          name: 'Class 10 CBSE • Mathematics',
          subject: 'Mathematics',
          timing: '04:30 PM - 06:00 PM • Mon, Wed, Fri',
          roomOrMeet: 'Room 101 • South Block',
          status: 'ACTIVE',
          statusType: StatusBadgeType.info,
          capacity: 30,
          studentIds: ['s1', 's2', 's3'],
        ),
        BatchItem(
          id: 'b2',
          name: 'NEET Droppers • Physics Mastery',
          subject: 'Physics',
          timing: '10:00 AM - 11:30 AM • Daily',
          roomOrMeet: 'Online (Google Meet)',
          status: 'NEXT CLASS',
          statusType: StatusBadgeType.warning,
          meetLink: 'https://meet.google.com/xyz-tuip-abc',
          capacity: 40,
          studentIds: ['s1', 's4'],
        ),
        BatchItem(
          id: 'b3',
          name: 'Class 12 ISC • Chemistry',
          subject: 'Chemistry',
          timing: '06:15 PM - 07:45 PM • Tue, Thu',
          roomOrMeet: 'Science Lab A',
          status: 'COMPLETED',
          statusType: StatusBadgeType.success,
          capacity: 25,
          studentIds: ['s2', 's3', 's5', 's6'],
        ),
      ]);
    });

    tearDown(() {
      Get.reset();
    });

    test('computes totalBatches and totalEnrolledStudents correctly', () {
      expect(controller.totalBatches, 3);
      expect(controller.totalEnrolledStudents, 9); // 3 + 2 + 4
    });

    test('filters batches by search query', () {
      controller.updateSearch('Physics');
      expect(controller.filteredBatches.length, 1);
      expect(controller.filteredBatches.first.name, contains('NEET Droppers'));

      controller.updateSearch('Room 101');
      expect(controller.filteredBatches.length, 1);
      expect(controller.filteredBatches.first.subject, 'Mathematics');

      controller.updateSearch('NonExistent');
      expect(controller.filteredBatches, isEmpty);
    });

    test('filters batches by category chip', () {
      // Online filter
      controller.setFilter('online');
      expect(controller.filteredBatches.length, 1);
      expect(controller.filteredBatches.first.isOnline, true);

      // Offline filter
      controller.setFilter('offline');
      expect(controller.filteredBatches.length, 2);
      expect(controller.filteredBatches.every((b) => !b.isOnline), true);

      // Today filter (contains 'Daily' or active schedule)
      controller.setFilter('today');
      expect(controller.filteredBatches.any((b) => b.timing.contains('Daily')), true);
    });
  });

  group('BatchesScreen Widget Tests', () {
    late BatchesController controller;

    setUp(() {
      Get.reset();
      controller = Get.put(BatchesController());
      controller.allBatches.assignAll([
        BatchItem(
          id: 'b1',
          name: 'Class 10 CBSE • Mathematics',
          subject: 'Mathematics',
          timing: '04:30 PM - 06:00 PM • Mon, Wed, Fri',
          roomOrMeet: 'Room 101 • South Block',
          status: 'ACTIVE',
          statusType: StatusBadgeType.info,
          capacity: 30,
          studentIds: ['s1', 's2', 's3'],
        ),
        BatchItem(
          id: 'b2',
          name: 'NEET Droppers • Physics',
          subject: 'Physics',
          timing: '10:00 AM - 11:30 AM • Daily',
          roomOrMeet: 'Online (Google Meet)',
          status: 'NEXT CLASS',
          statusType: StatusBadgeType.warning,
          meetLink: 'https://meet.google.com/xyz-tuip-abc',
          capacity: 40,
          studentIds: ['s1'],
        ),
      ]);
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('renders directory header, stats summary, and batch cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: BatchesScreen(),
          ),
        ),
      );
      await tester.pump();

      // Header
      expect(find.text('Batches Directory'), findsOneWidget);
      expect(find.text('2 Active'), findsOneWidget);

      // Stats
      expect(find.text('Batches'), findsOneWidget);
      expect(find.text('Students'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);

      // Batch cards content
      expect(find.text('Class 10 CBSE • Mathematics'), findsOneWidget);
      expect(find.text('04:30 PM - 06:00 PM • Mon, Wed, Fri'), findsOneWidget);
      expect(find.text('3 Students'), findsOneWidget);

      // Actions
      expect(find.text('Take Attendance'), findsNWidgets(2));
      expect(find.text('Roster'), findsNWidgets(2));
    });

    testWidgets('shows empty state when search finds no matches', (WidgetTester tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: BatchesScreen(),
          ),
        ),
      );
      await tester.pump();

      // Enter search query that matches nothing
      await tester.enterText(find.byType(TextField), 'Zoology 1234');
      await tester.pump();

      expect(find.text('No Batches Found'), findsOneWidget);
      expect(find.text('Reset Filters'), findsOneWidget);

      // Tap Reset Filters
      await tester.tap(find.text('Reset Filters'));
      await tester.pump();

      expect(find.text('Class 10 CBSE • Mathematics'), findsOneWidget);
    });
  });
}
