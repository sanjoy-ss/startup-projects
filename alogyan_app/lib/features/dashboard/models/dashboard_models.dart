class NeedsAttentionItem {
  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
  final bool isCritical;

  const NeedsAttentionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    this.isCritical = false,
  });
}

class ScheduledClassItem {
  final String id;
  final String timeRange;
  final String title;
  final String batchCode;
  final String location;
  final bool isOnline;
  final String status;
  final String? attendanceRecord;
  final bool isNextUp;

  const ScheduledClassItem({
    required this.id,
    required this.timeRange,
    required this.title,
    required this.batchCode,
    required this.location,
    required this.isOnline,
    required this.status,
    this.attendanceRecord,
    this.isNextUp = false,
  });
}

class ActivityLogItem {
  final String id;
  final String time;
  final String title;
  final String description;
  final String badgeText;
  final String? actionText;
  final String category; // 'lobby', 'notice', 'material', 'payment', 'attendance'

  const ActivityLogItem({
    required this.id,
    required this.time,
    required this.title,
    required this.description,
    required this.badgeText,
    this.actionText,
    required this.category,
  });
}

class WeeklyAttendanceData {
  final String day;
  final double percentage;
  final bool isPeak;
  final bool isToday;

  const WeeklyAttendanceData({
    required this.day,
    required this.percentage,
    this.isPeak = false,
    this.isToday = false,
  });
}

class OutstandingFeeStudent {
  final String id;
  final String studentName;
  final String rollNo;
  final String batchCode;
  final int dueAmount;
  final String dueDate;
  final bool isCritical;
  final String guardianContact;

  const OutstandingFeeStudent({
    required this.id,
    required this.studentName,
    required this.rollNo,
    required this.batchCode,
    required this.dueAmount,
    required this.dueDate,
    this.isCritical = false,
    required this.guardianContact,
  });
}

class CurriculumMaterialItem {
  final String id;
  final String title;
  final String batchCode;
  final String fileType; // 'pdf', 'code', 'link', 'video'
  final String fileSize;
  final String uploadDate;
  final bool isPinned;
  final bool isCached;

  const CurriculumMaterialItem({
    required this.id,
    required this.title,
    required this.batchCode,
    required this.fileType,
    required this.fileSize,
    required this.uploadDate,
    this.isPinned = false,
    this.isCached = false,
  });
}
