import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../attendance/controllers/attendance_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../students/controllers/students_controller.dart';
import '../data/repositories/batch_repository.dart';
import '../models/batch_model.dart';
import '../screens/batch_attendance_page.dart';
import '../widgets/batch_roster_sheet.dart';

class BatchesController extends GetxController {
  final BatchRepository? repository;

  final RxList<BatchItem> allBatches = <BatchItem>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs; // 'all', 'today', 'online', 'offline'
  final RxBool isLoading = false.obs;

  StreamSubscription? _batchSubscription;

  BatchesController({this.repository});

  @override
  void onInit() {
    super.onInit();
    _bindBatches();
  }

  void _bindBatches() {
    final repo = repository ??
        (Get.isRegistered<BatchRepository>()
            ? Get.find<BatchRepository>()
            : null);
    if (repo == null) return;

    final authCtrl = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;
    final instituteId = authCtrl?.currentUser.value?.instituteId;

    _batchSubscription?.cancel();
    _batchSubscription = repo.streamBatches(instituteId: instituteId).listen((batches) {
      allBatches.assignAll(batches);
    });
  }

  @override
  void onClose() {
    _batchSubscription?.cancel();
    super.onClose();
  }

  // --- Statistics & Aggregate Metrics ---
  int get totalBatches => allBatches.length;

  int get totalEnrolledStudents {
    int sum = 0;
    for (final b in allBatches) {
      sum += getEffectiveEnrolledCount(b);
    }
    return sum;
  }

  int get todaySessionsCount {
    return allBatches.where((b) {
      final s = b.status.toUpperCase();
      return s.contains('NEXT') ||
          s.contains('ACTIVE') ||
          b.timing.toLowerCase().contains('daily') ||
          _isBatchScheduledToday(b);
    }).length;
  }

  bool _isBatchScheduledToday(BatchItem batch) {
    final now = DateTime.now();
    final weekdays = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];
    final currentDay = weekdays[now.weekday - 1];
    final timingLower = batch.timing.toLowerCase();
    if (timingLower.contains('daily')) return true;
    return timingLower.contains(currentDay);
  }

  int getEffectiveEnrolledCount(BatchItem batch) {
    if (batch.studentIds.isNotEmpty) {
      return batch.studentIds.length;
    }
    if (Get.isRegistered<StudentsController>()) {
      final students = Get.find<StudentsController>().allStudents;
      final matched = students.where((s) {
        return s.batchIds.contains(batch.id) ||
            s.batch.toLowerCase().contains(batch.name.toLowerCase()) ||
            batch.name.toLowerCase().contains(s.batch.toLowerCase());
      }).length;
      if (matched > 0) return matched;
    }
    return batch.capacity > 0 ? (batch.capacity * 0.75).round() : 18;
  }

  List<StudentItem> getStudentsForBatch(BatchItem batch) {
    if (!Get.isRegistered<StudentsController>()) return [];
    final students = Get.find<StudentsController>().allStudents;
    return students.where((s) {
      if (batch.studentIds.contains(s.id)) return true;
      if (s.batchIds.contains(batch.id)) return true;
      if (batch.name.toLowerCase().contains(s.batch.toLowerCase()) ||
          s.batch.toLowerCase().contains(batch.name.toLowerCase())) {
        return true;
      }
      return false;
    }).toList();
  }

  // --- Filtering & Search ---
  List<BatchItem> get filteredBatches {
    final q = searchQuery.value.trim().toLowerCase();
    final filter = selectedFilter.value;

    return allBatches.where((b) {
      // 1. Search filter
      if (q.isNotEmpty) {
        final matchName = b.name.toLowerCase().contains(q);
        final matchSubject = b.subject.toLowerCase().contains(q);
        final matchRoom = b.roomOrMeet.toLowerCase().contains(q);
        final matchTiming = b.timing.toLowerCase().contains(q);
        if (!matchName && !matchSubject && !matchRoom && !matchTiming) {
          return false;
        }
      }

      // 2. Category filter
      switch (filter) {
        case 'today':
          return _isBatchScheduledToday(b) || b.status.toUpperCase().contains('NEXT');
        case 'online':
          return b.isOnline;
        case 'offline':
          return !b.isOnline;
        case 'all':
        default:
          return true;
      }
    }).toList();
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  // --- Direct Classroom Floor Actions ---
  Future<void> openMeetLink(String? url) async {
    if (url == null || url.isEmpty) {
      Get.snackbar(
        'No Meeting Link',
        'This batch does not have an active online meeting URL configured.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Could not open link',
        'Could not open $url',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  void openAttendance(BatchItem batch, BuildContext context) {
    if (Get.isRegistered<AttendanceController>()) {
      Get.find<AttendanceController>().selectBatch(batch);
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BatchAttendancePage(batch: batch),
      ),
    );
  }

  void showRoster(BatchItem batch, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BatchRosterSheet(batch: batch),
    );
  }

  Future<void> refreshBatches() async {
    isLoading.value = true;
    _bindBatches();
    await Future.delayed(const Duration(milliseconds: 500));
    isLoading.value = false;
  }
}
