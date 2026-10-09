import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/attendance/controllers/attendance_controller.dart';
import 'package:alogyan_app/features/attendance/screens/quick_attendance_screen.dart';
import 'package:alogyan_app/features/batches/models/batch_model.dart';
import 'package:alogyan_app/features/students/controllers/students_controller.dart';
import 'package:alogyan_app/shared/widgets/status_badge.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  testWidgets('QuickAttendanceScreen renders batch selector, batch details, and student toggles',
      (tester) async {
    final studentsCtrl = Get.put(StudentsController());
    studentsCtrl.allStudents.assignAll([
      StudentItem(
        id: 's_1',
        name: 'Aarav Patel',
        batch: 'Physics',
        batchIds: ['b_1'],
        phone: '9999911111',
        dueAmount: 0,
      ),
      StudentItem(
        id: 's_2',
        name: 'Diya Sharma',
        batch: 'Mathematics',
        batchIds: ['b_2'],
        phone: '9999922222',
        dueAmount: 0,
      ),
    ]);

    final batch1 = BatchItem(
      id: 'b_1',
      name: 'Class 10 - Physics Batch',
      subject: 'Physics',
      timing: '04:00 PM - 05:30 PM',
      roomOrMeet: 'Room 204',
      status: 'ACTIVE',
      statusType: StatusBadgeType.info,
      studentIds: ['s_1'],
      capacity: 30,
      meetLink: 'https://meet.google.com/xyz',
    );

    final batch2 = BatchItem(
      id: 'b_2',
      name: 'Class 10 - Math Batch',
      subject: 'Mathematics',
      timing: '05:30 PM - 07:00 PM',
      roomOrMeet: 'Room 205',
      status: 'ACTIVE',
      statusType: StatusBadgeType.info,
      studentIds: ['s_2'],
      capacity: 25,
    );

    final attendanceCtrl = Get.put(AttendanceController());
    attendanceCtrl.availableBatches.assignAll([batch1, batch2]);
    attendanceCtrl.selectBatch(batch1);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: QuickAttendanceScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Check Batch Selector ChoiceChips
    expect(find.text('Class 10 - Physics Batch'), findsWidgets);
    expect(find.text('Class 10 - Math Batch'), findsOneWidget);

    // 2. Check Action Bar
    expect(find.text('Mark All Present'), findsOneWidget);
    expect(find.text('All Absent'), findsOneWidget);

    // 3. Check Student Roster
    expect(find.text('Aarav Patel'), findsOneWidget);
    expect(find.text('Diya Sharma'), findsNothing); // Filtered out of Physics

    // 4. Tap student status to toggle
    expect(find.text('PRESENT'), findsOneWidget);
    await tester.tap(find.text('PRESENT'));
    await tester.pumpAndSettle();
    expect(find.text('ABSENT'), findsOneWidget);

    // 5. Test All Absent
    await tester.tap(find.text('All Absent'));
    await tester.pumpAndSettle();
    expect(find.text('ABSENT'), findsOneWidget);

    // 6. Test Mark All Present
    await tester.tap(find.text('Mark All Present'));
    await tester.pumpAndSettle();
    expect(find.text('PRESENT'), findsOneWidget);

    // 7. Test Batch switching via ChoiceChip
    await tester.tap(find.text('Class 10 - Math Batch'));
    await tester.pumpAndSettle();

    expect(find.text('Diya Sharma'), findsOneWidget);
    expect(find.text('Aarav Patel'), findsNothing);

    // 8. Tap batch details card to open bottom sheet
    await tester.tap(find.text('Class 10 - Math Batch').last);
    await tester.pumpAndSettle();

    expect(find.text('Class Schedule'), findsOneWidget);
    expect(find.text('Classroom / Mode'), findsOneWidget);
    expect(find.text('Roster Capacity'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
  });
}
