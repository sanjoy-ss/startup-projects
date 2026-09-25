import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/core/sync/sync_action.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SyncAction and Queue', () {
    test('action serializes with idempotency UUID', () {
      final action = SyncAction(
        type: 'COLLECT_FEE',
        endpoint: '/api/fees',
        payload: {'amount': '2500', 'student': 'Diya Sen'},
      );

      expect(action.id, isNotEmpty);
      expect(action.type, 'COLLECT_FEE');

      final map = action.toMap();
      final fromMap = SyncAction.fromMap(map);
      expect(fromMap.id, action.id);
      expect(fromMap.payload['amount'], '2500');
    });
  });
}
