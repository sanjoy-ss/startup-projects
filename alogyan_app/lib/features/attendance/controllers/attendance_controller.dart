import 'package:get/get.dart';
import '../../../core/sync/sync_action.dart';
import '../../../core/sync/sync_service.dart';

class AttendanceStudent {
  final String id;
  final String name;
  final String roll;
  String status;

  AttendanceStudent({
    required this.id,
    required this.name,
    required this.roll,
    this.status = 'present',
  });
}

class AttendanceController extends GetxController {
  final RxList<AttendanceStudent> students = <AttendanceStudent>[
    AttendanceStudent(id: '1', name: 'Aarav Sharma', roll: '101', status: 'present'),
    AttendanceStudent(id: '2', name: 'Diya Sen', roll: '102', status: 'present'),
    AttendanceStudent(id: '3', name: 'Ishaan Roy', roll: '103', status: 'absent'),
    AttendanceStudent(id: '4', name: 'Meera Patel', roll: '104', status: 'present'),
    AttendanceStudent(id: '5', name: 'Rohan Das', roll: '105', status: 'present'),
  ].obs;

  final RxBool isSubmitting = false.obs;

  int get presentCount => students.where((s) => s.status == 'present').length;
  int get totalCount => students.length;

  void toggleStatus(int index) {
    final student = students[index];
    if (student.status == 'present') {
      student.status = 'absent';
    } else if (student.status == 'absent') {
      student.status = 'late';
    } else {
      student.status = 'present';
    }
    students.refresh();
  }

  void markAllPresent() {
    for (final s in students) {
      s.status = 'present';
    }
    students.refresh();
  }

  Future<void> submitAttendance() async {
    isSubmitting.value = true;
    final records = <String, String>{};
    for (final s in students) {
      records[s.id] = s.status;
    }

    final action = SyncAction(
      type: 'MARK_ATTENDANCE',
      endpoint: '/api/attendance',
      payload: {
        'batchId': 'class_10_physics',
        'records': records,
      },
    );

    // Persist to offline sync queue
    if (Get.isRegistered<SyncService>()) {
      await Get.find<SyncService>().enqueue(action);
    }

    isSubmitting.value = false;
    Get.snackbar(
      'Attendance Saved',
      'Marked $presentCount/$totalCount present. Queued offline.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
