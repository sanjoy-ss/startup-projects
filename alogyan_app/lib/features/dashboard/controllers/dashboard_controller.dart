import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../attendance/controllers/attendance_controller.dart';
import '../../batches/models/batch_model.dart';
import '../../batches/screens/batch_attendance_page.dart';
import '../../batches/screens/batches_screen.dart';
import '../../students/controllers/students_controller.dart';
import '../../students/screens/students_screen.dart';
import '../models/dashboard_models.dart';
import '../screens/join_live_class_screen.dart';
import '../screens/fees_overview_screen.dart';
import '../screens/materials_notes_screen.dart';
import '../screens/whiteboard_screen.dart';

class DashboardController extends GetxController {
  final FirebaseFirestore? firestore;
  StreamSubscription? _scheduleSubscription;

  // View switch: 'teacher' (Teacher Home) or 'executive' (Executive Dashboard)
  final RxString currentDashboardTab = 'teacher'.obs;

  // Period switch for Executive view ('Today', 'This Week', 'Oct 2026')
  final RxString executivePeriod = 'Today'.obs;

  // ------------------ Teacher Home State ------------------
  final RxString upcomingClassTitle = 'Flutter Layouts and Responsive UI'.obs;
  final RxString upcomingBatchCode = 'Batch FL-01'.obs;
  final RxString upcomingCourseName = 'Flutter Foundations'.obs;
  final RxString upcomingClassTime = 'Today, 6:00 – 7:00 PM · Online (Google Meet)'.obs;
  final RxInt upcomingEnrolledCount = 24.obs;
  final RxString upcomingCountdown = 'Starts in 25 mins'.obs;
  final RxString upcomingClassUrl = 'https://meet.google.com/alo-gyan-xyz'.obs;

  final RxList<NeedsAttentionItem> needsAttentionItems = <NeedsAttentionItem>[
    const NeedsAttentionItem(
      id: 'att-1',
      title: 'Attendance not saved',
      subtitle: 'Yesterday’s MERN class (ME-01)',
      actionLabel: 'Resolve',
      isCritical: true,
    ),
    const NeedsAttentionItem(
      id: 'sub-2',
      title: '8 test submissions pending',
      subtitle: 'Dart Fundamentals assessment',
      actionLabel: 'Review',
      isCritical: false,
    ),
  ].obs;

  final RxList<ScheduledClassItem> scheduledClasses = <ScheduledClassItem>[
    const ScheduledClassItem(
      id: 'sc-1',
      timeRange: '10:00 AM – 11:30 AM',
      title: 'Computer Basics (CB-02)',
      batchCode: 'CB-02',
      location: 'Offline · Room 204',
      isOnline: false,
      status: 'Completed',
      attendanceRecord: '19/20 marked',
      isNextUp: false,
    ),
    const ScheduledClassItem(
      id: 'sc-2',
      timeRange: '04:00 PM – 05:00 PM',
      title: 'MERN Essentials (ME-01)',
      batchCode: 'ME-01',
      location: 'Online · Google Meet',
      isOnline: true,
      status: 'Completed',
      attendanceRecord: 'No record',
      isNextUp: false,
    ),
    const ScheduledClassItem(
      id: 'sc-3',
      timeRange: '06:00 PM – 07:00 PM',
      title: 'Flutter Foundations (FL-01)',
      batchCode: 'FL-01',
      location: 'Online · Room ready',
      isOnline: true,
      status: 'Next up',
      attendanceRecord: null,
      isNextUp: true,
    ),
  ].obs;

  final RxInt activeStudentsCount = 24.obs;
  final RxInt batchesTeachingCount = 3.obs;
  final RxInt feesCollectedThisMonth = 45000.obs;
  final RxInt outstandingFees = 12500.obs;
  final RxInt studentsDueCount = 5.obs;

  // ------------------ Executive Dashboard State ------------------
  final RxString campusName = 'Agartala Campus'.obs;
  final RxString campusDepartment = 'Session 2026–27 • Department of Mobile Development'.obs;
  final RxString campusStatus = 'Operational'.obs;
  final RxString syncStatus = 'Sync: 2m ago'.obs;

  final RxString executiveActiveStudents = '58/62'.obs;
  final RxString executiveCapacityRate = '93.5% cap'.obs;
  final RxString executiveAttendanceRate = '94.2%'.obs;
  final RxString executiveAttendanceTrend = 'vs 91.8% prev'.obs;
  final RxString executiveLecturesCount = '3/4'.obs;
  final RxString executiveNextLecture = 'Next: 06:00 PM Live'.obs;
  final RxString executiveFeeRealizationRate = '73%'.obs;
  final RxString executiveFeeCollectedSummary = '₹45k / ₹61.7k'.obs;

  final RxInt lobbyWaitingStudents = 14.obs;

  final RxList<WeeklyAttendanceData> weeklyAttendanceList = <WeeklyAttendanceData>[
    const WeeklyAttendanceData(day: 'M', percentage: 88.0),
    const WeeklyAttendanceData(day: 'T', percentage: 92.0),
    const WeeklyAttendanceData(day: 'W', percentage: 95.4, isPeak: true),
    const WeeklyAttendanceData(day: 'T', percentage: 91.0),
    const WeeklyAttendanceData(day: 'F', percentage: 93.0),
    const WeeklyAttendanceData(day: 'Sat', percentage: 94.2, isToday: true),
  ].obs;

  final RxInt feeTarget = 61700.obs;
  final RxInt feeRealized = 45000.obs;
  final RxInt feePending = 12500.obs;
  final RxInt feeOverdue = 4200.obs;

  final RxList<ActivityLogItem> activityLogItems = <ActivityLogItem>[
    const ActivityLogItem(
      id: 'log-1',
      time: '05:50 PM',
      title: 'Class Lobby Initialized',
      description: '14 students gathered for 6:00 PM Live Class (Flutter Layouts). Ready to broadcast.',
      badgeText: 'Batch FL-01',
      actionText: 'Open Lobby Console',
      category: 'lobby',
    ),
    const ActivityLogItem(
      id: 'log-2',
      time: '04:45 PM',
      title: 'Payment Notices Dispatched',
      description: 'Automated WhatsApp & SMS payment link sent to 14 fee-due guardians (Agartala center).',
      badgeText: '14 Delivered',
      actionText: 'Gateway: Fast2SMS',
      category: 'notice',
    ),
    const ActivityLogItem(
      id: 'log-3',
      time: '02:00 PM',
      title: 'Lecture Material Uploaded',
      description: "Published 'Flutter Layout Practice.pdf' (2.4 MB) with starter templates.",
      badgeText: 'FL-01 Handout',
      actionText: 'Preview Document',
      category: 'material',
    ),
    const ActivityLogItem(
      id: 'log-4',
      time: '12:15 PM',
      title: 'Tuition Payment Received',
      description: '₹1,000 received via UPI (PhonePe) for Riya Das by Subrata Das. Cleared October installment.',
      badgeText: 'Txn #UP-9841',
      actionText: 'Download Receipt',
      category: 'payment',
    ),
    const ActivityLogItem(
      id: 'log-5',
      time: '10:30 AM',
      title: 'Morning Attendance Locked',
      description: 'Batch FL-01 (Flutter Foundations) — 23 Present, 1 Excused leave (Riya Das - medical memo verified).',
      badgeText: '95.8% present',
      actionText: 'View Class Register',
      category: 'attendance',
    ),
  ].obs;

  // Real-time batch sync fallback
  final RxList<BatchItem> todaySchedule = <BatchItem>[].obs;
  final RxInt totalPendingDues = 0.obs;

  DashboardController({this.firestore});

  @override
  void onInit() {
    super.onInit();
    _bindScheduleStream();
    _bindPendingDues();
  }

  void switchDashboardTab(String tab) {
    currentDashboardTab.value = tab;
  }

  void setExecutivePeriod(String period) {
    executivePeriod.value = period;
  }

  void resolveAttentionItem(String id) {
    needsAttentionItems.removeWhere((item) => item.id == id);
    Get.snackbar(
      'Action Completed',
      'Pending issue has been addressed successfully.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void _bindPendingDues() {
    final ctrl = Get.isRegistered<StudentsController>()
        ? Get.find<StudentsController>()
        : Get.put(StudentsController());
    totalPendingDues.value = ctrl.allStudents.fold(0, (acc, s) => acc + s.dueAmount);
    ever(ctrl.allStudents, (students) {
      totalPendingDues.value = students.fold(0, (acc, s) => acc + s.dueAmount);
    });
  }

  void _bindScheduleStream() {
    final authCtrl = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    final user = authCtrl?.currentUser.value;
    loadScheduleForInstitute(user?.instituteId);

    if (authCtrl != null) {
      ever(authCtrl.currentUser, (u) {
        loadScheduleForInstitute(u?.instituteId);
      });
    }
  }

  void loadScheduleForInstitute(String? instituteId) {
    _scheduleSubscription?.cancel();
    try {
      final db = firestore ?? FirebaseFirestore.instance;
      Query<Map<String, dynamic>> query = db.collection('batches');
      if (instituteId != null && instituteId.isNotEmpty) {
        query = query.where('instituteId', isEqualTo: instituteId);
      }

      _scheduleSubscription = query.snapshots().listen(
        (snapshot) {
          final batches = snapshot.docs.map((doc) {
            return BatchItem.fromMap(doc.id, doc.data());
          }).toList();
          todaySchedule.assignAll(batches);
          if (batches.isNotEmpty) {
            batchesTeachingCount.value = batches.length;
          }
        },
        onError: (e) {
          debugPrint('Notice streaming today batches: $e');
        },
      );
    } catch (e) {
      debugPrint('Firestore offline fallback for dashboard schedule: $e');
    }
  }

  @override
  void onClose() {
    _scheduleSubscription?.cancel();
    super.onClose();
  }

  int get todayClassesCount => todaySchedule.isNotEmpty ? todaySchedule.length : scheduledClasses.length;

  Future<void> launchClassLink(String? url) async {
    final targetUrl = url ?? upcomingClassUrl.value;
    if (targetUrl.isEmpty) return;
    final uri = Uri.parse(targetUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void navigateToTakeAttendance(BatchItem batch) {
    if (Get.isRegistered<AttendanceController>()) {
      Get.find<AttendanceController>().selectBatch(batch);
    }
    Get.to(() => BatchAttendancePage(batch: batch));
  }

  // Navigation actions linking to Stitch project sub-pages
  void openJoinLiveClass() {
    Get.to(() => const JoinLiveClassScreen());
  }

  void openWhiteboard() {
    Get.to(() => const WhiteboardScreen());
  }

  void openFeesOverview() {
    Get.to(() => const FeesOverviewScreen());
  }

  void openMaterialsNotes() {
    Get.to(() => const MaterialsNotesScreen());
  }

  void openStudentsList() {
    Get.to(() => const StudentsScreen());
  }

  void openBatchesList() {
    Get.to(() => const BatchesScreen());
  }
}
