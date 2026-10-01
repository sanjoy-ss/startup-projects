import 'package:get/get.dart';
import '../../students/controllers/students_controller.dart';
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

  final RxList<AttendanceStudent> students = <AttendanceStudent>[].obs;
  final RxBool isSubmitting = false.obs;

  AttendanceController({this.repository});

  @override
  void onInit() {
    super.onInit();
    syncRosterFromStudents();

    if (Get.isRegistered<StudentsController>()) {
      ever(Get.find<StudentsController>().allStudents, (_) {
        syncRosterFromStudents();
      });
    }

    final repo = repository ??
        (Get.isRegistered<AttendanceRepository>()
            ? Get.find<AttendanceRepository>()
            : null);
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

  void syncRosterFromStudents() {
    if (Get.isRegistered<StudentsController>()) {
      final studentsCtrl = Get.find<StudentsController>();
      final currentMap = {for (final s in students) s.id: s.status};
      final newStudents = studentsCtrl.allStudents.map((s) {
        return AttendanceStudent(
          id: s.id,
          name: s.name,
          roll: s.id,
          status: currentMap[s.id] ?? 'present',
        );
      }).toList();
      students.assignAll(newStudents);
    }
  }

  int get presentCount => students.where((s) => s.status == 'present').length;
  int get totalCount => students.length;

  void toggleStatus(int index) {
    if (index < 0 || index >= students.length) return;
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
    if (students.isEmpty) {
      Get.snackbar(
        'Empty Roster',
        'Cannot record attendance when no students are enrolled in this batch.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isSubmitting.value = true;
    final records = <String, String>{};
    for (final s in students) {
      records[s.id] = s.status;
    }

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final repo = repository ??
        (Get.isRegistered<AttendanceRepository>()
            ? Get.find<AttendanceRepository>()
            : null);

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
