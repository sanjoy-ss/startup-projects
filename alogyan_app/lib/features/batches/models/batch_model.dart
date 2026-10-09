import '../../../shared/widgets/status_badge.dart';

class BatchItem {
  final String id;
  final String name;
  final String subject;
  final String timing;
  final String roomOrMeet;
  final String status;
  final StatusBadgeType statusType;
  final String? meetLink;
  final List<String> studentIds;
  final int capacity;
  final String? branchId;
  final String? instituteId;

  BatchItem({
    required this.id,
    required this.name,
    this.subject = 'General',
    required this.timing,
    required this.roomOrMeet,
    required this.status,
    required this.statusType,
    this.meetLink,
    this.studentIds = const [],
    this.capacity = 0,
    this.branchId,
    this.instituteId,
  });

  int get enrolledCount => studentIds.length;
  String get time => timing;
  String get batchName => name;

  bool get isOnline =>
      (meetLink != null && meetLink!.isNotEmpty) ||
      roomOrMeet.toLowerCase().contains('online') ||
      roomOrMeet.toLowerCase().contains('meet') ||
      roomOrMeet.toLowerCase().contains('zoom');

  factory BatchItem.fromMap(String id, Map<String, dynamic> data) {
    final statusStr = (data['status'] as String?)?.toUpperCase() ?? 'ACTIVE';
    StatusBadgeType type = StatusBadgeType.info;
    if (statusStr.contains('NEXT')) {
      type = StatusBadgeType.warning;
    } else if (statusStr.contains('ONLINE') || statusStr.contains('ACTIVE')) {
      type = StatusBadgeType.info;
    } else if (statusStr.contains('COMPLETED')) {
      type = StatusBadgeType.success;
    }

    final rawStudentIds = data['studentIds'];
    final List<String> parsedStudentIds = [];
    if (rawStudentIds is List) {
      for (final item in rawStudentIds) {
        if (item != null) parsedStudentIds.add(item.toString());
      }
    }

    return BatchItem(
      id: id,
      name: (data['name'] as String?) ??
          (data['batchName'] as String?) ??
          'Batch Session',
      subject: (data['subject'] as String?) ?? 'General',
      timing: (data['timing'] as String?) ??
          (data['time'] as String?) ??
          'Time TBD',
      roomOrMeet: (data['roomOrMeet'] as String?) ??
          (data['room'] as String?) ??
          'Main Hall',
      status: statusStr,
      statusType: type,
      meetLink: data['meetLink'] as String?,
      studentIds: parsedStudentIds,
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
      branchId: data['branchId'] as String?,
      instituteId: (data['instituteId'] as String?) ??
          (data['teacherId'] as String?),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'subject': subject,
        'timing': timing,
        'roomOrMeet': roomOrMeet,
        'status': status,
        'meetLink': meetLink,
        'studentIds': studentIds,
        'capacity': capacity,
        'branchId': branchId,
        'instituteId': instituteId,
      };
}
