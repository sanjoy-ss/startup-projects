import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../shared/widgets/status_badge.dart';
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
}

class DashboardController extends GetxController {
  final RxList<BatchScheduleItem> todaySchedule = <BatchScheduleItem>[
    BatchScheduleItem(
      id: 'b1',
      time: '04:00 PM - 05:30 PM',
      batchName: 'Class 10 - Advanced Physics',
      roomOrMeet: 'Room 201 (Offline Floor)',
      status: 'NEXT CLASS',
      statusType: StatusBadgeType.warning,
    ),
    BatchScheduleItem(
      id: 'b2',
      time: '06:00 PM - 07:30 PM',
      batchName: 'Class 12 - Calculus Masterclass',
      roomOrMeet: 'Google Meet (1-tap start)',
      status: 'ONLINE',
      statusType: StatusBadgeType.info,
      meetLink: 'https://meet.google.com/alo-gyan-edu',
    ),
    BatchScheduleItem(
      id: 'b3',
      time: '08:00 PM - 09:00 PM',
      batchName: 'Doubt Clearing & Numericals',
      roomOrMeet: 'Room 102',
      status: 'SCHEDULED',
      statusType: StatusBadgeType.info,
    ),
  ].obs;

  final RxInt fallbackPendingDues = 7500.obs;

  int get todayClassesCount => todaySchedule.length;

  int get totalPendingDues {
    if (Get.isRegistered<StudentsController>()) {
      final ctrl = Get.find<StudentsController>();
      return ctrl.allStudents.fold(0, (sum, s) => sum + s.dueAmount);
    }
    return fallbackPendingDues.value;
  }

  Future<void> launchClassLink(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
