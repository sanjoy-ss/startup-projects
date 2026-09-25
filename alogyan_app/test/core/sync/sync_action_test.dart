import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/core/sync/sync_action.dart';

void main() {
  group('SyncAction', () {
    test('instantiates with unique UUID and serialization roundtrip', () {
      final action = SyncAction(
        type: 'MARK_ATTENDANCE',
        endpoint: '/api/attendance',
        payload: {
          'batchId': 'b_101',
          'records': {'s_1': 'present', 's_2': 'absent'}
        },
      );

      expect(action.id, isNotEmpty);
      expect(action.status, 'pending');
      expect(action.retryCount, 0);

      final map = action.toMap();
      final restored = SyncAction.fromMap(map);

      expect(restored.id, action.id);
      expect(restored.type, 'MARK_ATTENDANCE');
      expect(restored.endpoint, '/api/attendance');
      expect(restored.payload['batchId'], 'b_101');
    });
  });
}
