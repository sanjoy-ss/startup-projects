import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/features/batches/models/batch_model.dart';
import 'package:alogyan_app/shared/widgets/status_badge.dart';

void main() {
  group('BatchItem Model Tests (CMS Web Parity)', () {
    test('correctly parses CMS web batches collection document', () {
      final data = {
        'name': 'Class 10 - Physics Batch',
        'subject': 'Physics',
        'timing': '04:00 PM - 05:30 PM',
        'roomOrMeet': 'Room 204',
        'status': 'ACTIVE',
        'studentIds': ['student_1', 'student_2', 'student_3'],
        'capacity': 30,
        'branchId': 'branch_main',
        'instituteId': 'inst_123',
        'meetLink': 'https://meet.google.com/abc-defg-hij',
      };

      final batch = BatchItem.fromMap('b_100', data);

      expect(batch.id, 'b_100');
      expect(batch.name, 'Class 10 - Physics Batch');
      expect(batch.batchName, 'Class 10 - Physics Batch');
      expect(batch.subject, 'Physics');
      expect(batch.timing, '04:00 PM - 05:30 PM');
      expect(batch.time, '04:00 PM - 05:30 PM');
      expect(batch.roomOrMeet, 'Room 204');
      expect(batch.status, 'ACTIVE');
      expect(batch.statusType, StatusBadgeType.info);
      expect(batch.studentIds, ['student_1', 'student_2', 'student_3']);
      expect(batch.enrolledCount, 3);
      expect(batch.capacity, 30);
      expect(batch.branchId, 'branch_main');
      expect(batch.instituteId, 'inst_123');
      expect(batch.isOnline, true);
    });

    test('handles fallback legacy batch fields', () {
      final legacyData = {
        'batchName': 'Chemistry Batch',
        'time': '10:00 AM',
        'room': 'Lab 2',
        'status': 'COMPLETED',
        'teacherId': 'teacher_456',
      };

      final batch = BatchItem.fromMap('b_200', legacyData);

      expect(batch.id, 'b_200');
      expect(batch.name, 'Chemistry Batch');
      expect(batch.timing, '10:00 AM');
      expect(batch.roomOrMeet, 'Lab 2');
      expect(batch.status, 'COMPLETED');
      expect(batch.statusType, StatusBadgeType.success);
      expect(batch.studentIds, isEmpty);
      expect(batch.enrolledCount, 0);
      expect(batch.instituteId, 'teacher_456');
      expect(batch.isOnline, false);
    });

    test('toMap produces consistent data map', () {
      final batch = BatchItem(
        id: 'b_300',
        name: 'Maths Advanced',
        subject: 'Mathematics',
        timing: '06:00 PM',
        roomOrMeet: 'Online',
        status: 'ACTIVE',
        statusType: StatusBadgeType.info,
        studentIds: ['s1'],
        capacity: 25,
      );

      final map = batch.toMap();
      expect(map['id'], 'b_300');
      expect(map['name'], 'Maths Advanced');
      expect(map['subject'], 'Mathematics');
      expect(map['studentIds'], ['s1']);
      expect(map['capacity'], 25);
    });
  });
}
