import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/navigation/controllers/navigation_controller.dart';
import 'package:alogyan_app/features/attendance/controllers/attendance_controller.dart';
import 'package:alogyan_app/features/fees/controllers/fee_controller.dart';
import 'package:alogyan_app/features/students/controllers/students_controller.dart';
import 'package:alogyan_app/features/dashboard/controllers/dashboard_controller.dart';

void main() {
  group('NavigationController', () {
    test('initializes at index 0 and updates tab reactively', () {
      final controller = NavigationController();
      expect(controller.currentIndex.value, 0);

      controller.changeTab(2);
      expect(controller.currentIndex.value, 2);
    });
  });

  group('AttendanceController', () {
    test('toggles attendance status and counts correctly', () {
      final controller = AttendanceController();
      final initialPresent = controller.presentCount;

      controller.toggleStatus(0); // 1st student was present -> absent
      expect(controller.students[0].status, 'absent');
      expect(controller.presentCount, initialPresent - 1);

      controller.markAllPresent();
      expect(controller.presentCount, controller.totalCount);
    });
  });

  group('FeeController', () {
    test('updates amount and payment mode', () {
      final controller = FeeController();
      expect(controller.paymentMode.value, 'upi');

      controller.setPaymentMode('cash');
      expect(controller.paymentMode.value, 'cash');

      controller.updateAmount('3500');
      expect(controller.amount.value, '3500');
    });
  });

  group('StudentsController and Settlement', () {
    test('filters students by search query and settles due balance', () {
      final controller = StudentsController();
      expect(controller.filteredStudents.length, 5);

      controller.updateSearch('diya');
      expect(controller.filteredStudents.length, 1);
      expect(controller.filteredStudents.first.name, 'Diya Sen');

      final initialDue = controller.totalPendingDues;
      expect(initialDue, greaterThan(0));

      // Settle Diya Sen's due
      controller.settleStudentDue('2', 2000);
      final diya = controller.allStudents.firstWhere((s) => s.id == '2');
      expect(diya.dueAmount, 0);
      expect(controller.totalPendingDues, initialDue - 2000);
    });
  });

  group('DashboardController', () {
    test('computes total classes and pending dues', () {
      Get.testMode = true;
      Get.put(StudentsController());
      final controller = Get.put(DashboardController());

      expect(controller.todayClassesCount, 3);
      expect(controller.totalPendingDues, greaterThan(0));
    });
  });
}
