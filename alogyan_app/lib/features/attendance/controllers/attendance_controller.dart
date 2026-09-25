import 'package:get/get.dart';
import '../data/repositories/attendance_repository.dart';

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
  final AttendanceRepository? repository;

  final RxList<AttendanceStudent> students = <AttendanceStudent>[
    AttendanceStudent(id: '1', name: 'Aarav Sharma', roll: '101', status: 'present'),
    AttendanceStudent(id: '2', name: 'Diya Sen', roll: '102', status: 'present'),
    AttendanceStudent(id: '3', name: 'Ishaan Roy', roll: '103', status: 'absent'),
    AttendanceStudent(id: '4', name: 'Meera Patel', roll: '104', status: 'present'),
    AttendanceStudent(id: '5', name: 'Rohan Das', roll: '105', status: 'present'),
  ].obs;

  final RxBool isSubmitting = false.obs;

  AttendanceController({this.repository});

  @override
  void onInit() {
    super.onInit();
    final repo = repository ?? (Get.isRegistered<AttendanceRepository>() ? Get.find<AttendanceRepository>() : null);
    if (repo != null) {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      repo.streamAttendance('class_10_physics', today).listen((records) {
        if (records.isNotEmpty) {
          for (final s in students) {
            if (records.containsKey(s.id)) {
              s.status = records[s.id]!;
            }
          }
          students.refresh();
        }
      });
    }
  }

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

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final repo = repository ?? (Get.isRegistered<AttendanceRepository>() ? Get.find<AttendanceRepository>() : null);

    if (repo != null) {
      await repo.saveAttendance('class_10_physics', today, records);
    }

    isSubmitting.value = false;
    Get.snackbar(
      'Attendance Saved',
      'Marked $presentCount/$totalCount present. Queued offline & syncing.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
