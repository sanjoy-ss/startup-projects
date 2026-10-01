import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../students/controllers/students_controller.dart';

class BatchScheduleItem {
  final String id;
  final String time;
  final String batchName;
  final String roomOrMeet;
  final String status;
  final StatusBadgeType statusType;
  final String? meetLink;

  BatchScheduleItem({
    required this.id,
    required this.time,
    required this.batchName,
    required this.roomOrMeet,
    required this.status,
    required this.statusType,
    this.meetLink,
  });

  factory BatchScheduleItem.fromMap(String id, Map<String, dynamic> data) {
    final statusStr = (data['status'] as String?)?.toUpperCase() ?? 'SCHEDULED';
    StatusBadgeType type = StatusBadgeType.info;
    if (statusStr.contains('NEXT')) {
      type = StatusBadgeType.warning;
    } else if (statusStr.contains('ONLINE') || statusStr.contains('ACTIVE')) {
      type = StatusBadgeType.info;
    } else if (statusStr.contains('COMPLETED')) {
      type = StatusBadgeType.success;
    }

    return BatchScheduleItem(
      id: id,
      time: (data['time'] as String?) ?? 'Time TBD',
      batchName: (data['batchName'] as String?) ?? (data['name'] as String?) ?? 'Batch Session',
      roomOrMeet: (data['roomOrMeet'] as String?) ?? (data['room'] as String?) ?? 'Main Hall',
      status: statusStr,
      statusType: type,
      meetLink: data['meetLink'] as String?,
    );
  }
}

class DashboardController extends GetxController {
  final FirebaseFirestore? firestore;
  StreamSubscription? _scheduleSubscription;

  final RxList<BatchScheduleItem> todaySchedule = <BatchScheduleItem>[].obs;

  DashboardController({this.firestore});

  @override
  void onInit() {
    super.onInit();
    _bindScheduleStream();
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
            return BatchScheduleItem.fromMap(doc.id, doc.data());
          }).toList();
          todaySchedule.assignAll(batches);
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

  int get todayClassesCount => todaySchedule.length;

  int get totalPendingDues {
    if (Get.isRegistered<StudentsController>()) {
      final ctrl = Get.find<StudentsController>();
      return ctrl.allStudents.fold(0, (sum, s) => sum + s.dueAmount);
    }
    return 0;
  }

  Future<void> launchClassLink(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
