import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/attendance/controllers/attendance_controller.dart';
import 'package:alogyan_app/features/students/controllers/students_controller.dart';

void main() {
  test('AttendanceController roster synchronizes with StudentsController', () {
    Get.reset();
    final studentsCtrl = Get.put(StudentsController());
    final attendanceCtrl = Get.put(AttendanceController());

    expect(attendanceCtrl.students, isEmpty, reason: 'Attendance roster must not have hardcoded dummy students');

    studentsCtrl.allStudents.add(
      StudentItem(id: 's_10', name: 'Kabir Das', batch: 'Physics', phone: '+919876543210', dueAmount: 0),
    );
    attendanceCtrl.syncRosterFromStudents();

    expect(attendanceCtrl.students.length, 1);
    expect(attendanceCtrl.students.first.name, 'Kabir Das');
    expect(attendanceCtrl.presentCount, 1);
  });
}
