import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/dashboard/controllers/dashboard_controller.dart';
import 'package:alogyan_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:alogyan_app/features/students/controllers/students_controller.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('DashboardController initializes with empty schedule and 0 dues', () {
    final controller = DashboardController();
    controller.onInit();

    expect(controller.todaySchedule, isEmpty);
    expect(controller.todayClassesCount, 0);
    expect(controller.totalPendingDues, 0);
  });

  test('DashboardController computes pending dues dynamically from StudentsController', () {
    final studentsCtrl = Get.put(StudentsController());
    studentsCtrl.allStudents.assignAll([
      StudentItem(id: 's1', name: 'Student 1', batch: 'Batch A', phone: '123', dueAmount: 1200),
      StudentItem(id: 's2', name: 'Student 2', batch: 'Batch B', phone: '456', dueAmount: 800),
    ]);

    final controller = DashboardController();
    controller.onInit();

    expect(controller.totalPendingDues, 2000);
  });

  testWidgets('DashboardScreen displays empty schedule card when no classes today', (WidgetTester tester) async {
    final studentsCtrl = Get.put(StudentsController());
    studentsCtrl.allStudents.clear();

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: DashboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No Classes Scheduled Today'), findsOneWidget);
    expect(find.text('0 classes scheduled'), findsOneWidget);
    expect(find.text('0 Batches'), findsOneWidget);
    expect(find.text('₹0'), findsOneWidget);
  });
}
