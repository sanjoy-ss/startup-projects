import 'dart:async';

import 'package:get/get.dart';

import '../../auth/controllers/auth_controller.dart';
import '../../batches/data/repositories/batch_repository.dart';
import '../../batches/models/batch_model.dart';
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
  final BatchRepository? batchRepository;

  final RxList<BatchItem> availableBatches = <BatchItem>[].obs;
  final Rxn<BatchItem> selectedBatch = Rxn<BatchItem>();
  final RxString selectedDate = ''.obs;

  final RxList<AttendanceStudent> students = <AttendanceStudent>[].obs;
  final RxBool isSubmitting = false.obs;

  StreamSubscription? _attendanceSub;
  StreamSubscription? _batchesSub;

  AttendanceController({this.repository, this.batchRepository});

  @override
  void onInit() {
    super.onInit();
    selectedDate.value = DateTime.now().toIso8601String().substring(0, 10);

    _initBatchStream();
    syncRosterFromStudents();

    if (Get.isRegistered<StudentsController>()) {
      ever(Get.find<StudentsController>().allStudents, (_) {
        syncRosterFromStudents();
      });
    }

    ever(selectedBatch, (batch) {
      syncRosterFromStudents();
      _bindAttendanceStream();
    });
  }

  void _initBatchStream() {
    final batchRepo =
        batchRepository ??
        (Get.isRegistered<BatchRepository>()
            ? Get.find<BatchRepository>()
            : null);

    if (batchRepo != null) {
      final authCtrl = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : null;
      final instituteId = authCtrl?.currentUser.value?.instituteId;

      _batchesSub?.cancel();
      _batchesSub = batchRepo.streamBatches(instituteId: instituteId).listen((
        batches,
      ) {
        availableBatches.assignAll(batches);
        if (batches.isNotEmpty) {
          if (selectedBatch.value == null ||
              !batches.any((b) => b.id == selectedBatch.value!.id)) {
            selectedBatch.value = batches.first;
          }
        }
      });
    }
  }

  void selectBatch(BatchItem batch) {
    selectedBatch.value = batch;
  }

  void _bindAttendanceStream() {
    _attendanceSub?.cancel();
    final currentBatch = selectedBatch.value;
    if (currentBatch == null) return;

    final repo =
        repository ??
        (Get.isRegistered<AttendanceRepository>()
            ? Get.find<AttendanceRepository>()
            : null);

    if (repo != null) {
      final date = selectedDate.value;
      _attendanceSub = repo.streamAttendance(currentBatch.id, date).listen((
        records,
      ) {
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
      final currentBatch = selectedBatch.value;
      final currentMap = {for (final s in students) s.id: s.status};

      final List<StudentItem> filtered;
      if (currentBatch != null) {
        filtered = studentsCtrl.allStudents.where((s) {
          if (currentBatch.studentIds.contains(s.id)) return true;
          if (s.batchIds.contains(currentBatch.id)) return true;
          if (s.batch.toLowerCase() == currentBatch.name.toLowerCase() ||
              s.batch.toLowerCase() == currentBatch.subject.toLowerCase()) {
            return true;
          }
          return false;
        }).toList();
      } else {
        filtered = studentsCtrl.allStudents;
      }

      final newStudents = filtered.map((s) {
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
  int get absentCount => students.where((s) => s.status == 'absent').length;
  int get lateCount => students.where((s) => s.status == 'late').length;
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

  void markAllAbsent() {
    for (final s in students) {
      s.status = 'absent';
    }
    students.refresh();
  }

  Future<void> submitAttendance() async {
    final batch = selectedBatch.value;
    if (batch == null && availableBatches.isNotEmpty) {
      Get.snackbar(
        'Select Batch',
        'Please select an active batch to record attendance.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

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

    final batchId = batch?.id ?? 'general';
    final date = selectedDate.value.isNotEmpty
        ? selectedDate.value
        : DateTime.now().toIso8601String().substring(0, 10);

    final authCtrl = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;
    final user = authCtrl?.currentUser.value;

    final repo =
        repository ??
        (Get.isRegistered<AttendanceRepository>()
            ? Get.find<AttendanceRepository>()
            : null);

    if (repo != null) {
      await repo.saveAttendance(
        batchId,
        date,
        records,
        instituteId: user?.instituteId,
        teacherId: user?.uid,
      );
    }

    isSubmitting.value = false;
    final batchLabel = batch?.name ?? 'Batch';
    Get.snackbar(
      'Attendance Saved',
      'Marked $presentCount/$totalCount present for $batchLabel. Queued offline & syncing.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    _attendanceSub?.cancel();
    _batchesSub?.cancel();
    super.onClose();
  }
}
