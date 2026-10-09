import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/attendance/controllers/attendance_controller.dart';
import 'package:alogyan_app/features/batches/models/batch_model.dart';
import 'package:alogyan_app/features/students/controllers/students_controller.dart';
import 'package:alogyan_app/shared/widgets/status_badge.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  group('AttendanceController Batch-Wise Tests', () {
    test('AttendanceController roster synchronizes with StudentsController', () {
      final studentsCtrl = Get.put(StudentsController());
      final attendanceCtrl = Get.put(AttendanceController());

      expect(attendanceCtrl.students, isEmpty,
          reason: 'Attendance roster must not have hardcoded dummy students');

      studentsCtrl.allStudents.add(
        StudentItem(
          id: 's_10',
          name: 'Kabir Das',
          batch: 'Physics',
          phone: '+919876543210',
          dueAmount: 0,
        ),
      );
      attendanceCtrl.syncRosterFromStudents();

      expect(attendanceCtrl.students.length, 1);
      expect(attendanceCtrl.students.first.name, 'Kabir Das');
      expect(attendanceCtrl.presentCount, 1);
    });

    test('filters students strictly by selectedBatch studentIds', () {
      final studentsCtrl = Get.put(StudentsController());
      studentsCtrl.allStudents.assignAll([
        StudentItem(
          id: 's_1',
          name: 'Aarav Patel',
          batch: 'Physics',
          batchIds: ['batch_phys'],
          phone: '9999911111',
          dueAmount: 0,
        ),
        StudentItem(
          id: 's_2',
          name: 'Diya Sharma',
          batch: 'Mathematics',
          batchIds: ['batch_math'],
          phone: '9999922222',
          dueAmount: 0,
        ),
        StudentItem(
          id: 's_3',
          name: 'Ishaan Verma',
          batch: 'Physics',
          batchIds: ['batch_phys'],
          phone: '9999933333',
          dueAmount: 0,
        ),
      ]);

      final batchPhys = BatchItem(
        id: 'batch_phys',
        name: 'Class 10 - Physics Batch',
        subject: 'Physics',
        timing: '04:00 PM',
        roomOrMeet: 'Room 101',
        status: 'ACTIVE',
        statusType: StatusBadgeType.info,
        studentIds: ['s_1', 's_3'],
      );

      final batchMath = BatchItem(
        id: 'batch_math',
        name: 'Class 10 - Math Batch',
        subject: 'Mathematics',
        timing: '05:30 PM',
        roomOrMeet: 'Room 102',
        status: 'ACTIVE',
        statusType: StatusBadgeType.info,
        studentIds: ['s_2'],
      );

      final attendanceCtrl = Get.put(AttendanceController());
      attendanceCtrl.availableBatches.assignAll([batchPhys, batchMath]);

      // 1. Select Physics Batch
      attendanceCtrl.selectBatch(batchPhys);
      expect(attendanceCtrl.selectedBatch.value?.id, 'batch_phys');
      expect(attendanceCtrl.students.length, 2);
      expect(attendanceCtrl.students.map((s) => s.id).toList(), ['s_1', 's_3']);
      expect(attendanceCtrl.presentCount, 2);
      expect(attendanceCtrl.absentCount, 0);

      // 2. Mark student absent & toggle
      attendanceCtrl.toggleStatus(0); // s_1 -> absent
      expect(attendanceCtrl.students[0].status, 'absent');
      expect(attendanceCtrl.presentCount, 1);
      expect(attendanceCtrl.absentCount, 1);

      // 3. Mark all absent
      attendanceCtrl.markAllAbsent();
      expect(attendanceCtrl.absentCount, 2);
      expect(attendanceCtrl.presentCount, 0);

      // 4. Mark all present
      attendanceCtrl.markAllPresent();
      expect(attendanceCtrl.presentCount, 2);
      expect(attendanceCtrl.absentCount, 0);

      // 5. Switch to Math Batch
      attendanceCtrl.selectBatch(batchMath);
      expect(attendanceCtrl.selectedBatch.value?.id, 'batch_math');
      expect(attendanceCtrl.students.length, 1);
      expect(attendanceCtrl.students.first.name, 'Diya Sharma');
      expect(attendanceCtrl.presentCount, 1);
    });
  });
}
