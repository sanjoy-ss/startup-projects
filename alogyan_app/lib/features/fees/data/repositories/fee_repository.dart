import 'package:uuid/uuid.dart';
import '../../../../core/cache/cache_service.dart';
import '../../../../core/sync/sync_action.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/sync/sync_worker.dart';

class FeeRepository {
  final CacheService cacheService;
  final SyncService syncService;
  final SyncWorker? syncWorker;

  FeeRepository({
    required this.cacheService,
    required this.syncService,
    this.syncWorker,
  });

  Future<String> recordPayment({
    required String studentName,
    required String amount,
    required String paymentMode,
  }) async {
    final paymentId = const Uuid().v4();
    final receiptNumber = 'REC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final paymentData = {
      'id': paymentId,
      'receiptNumber': receiptNumber,
      'student': studentName,
      'amount': amount,
      'mode': paymentMode,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // 1. Cache fee record in local Hive box
    await cacheService.cacheFeePayment(paymentData);

    // 2. Queue SyncAction with client idempotency key
    final action = SyncAction(
      id: paymentId,
      type: 'COLLECT_FEE',
      endpoint: '/api/fees',
      payload: paymentData,
    );
    await syncService.enqueue(action);
    syncWorker?.refreshPendingCount();

    // 3. Trigger background sync if online
    syncWorker?.drainQueue();

    // 4. Return formatted WhatsApp receipt text
    return 'Payment Received: ₹$amount for $studentName (Mode: ${paymentMode.toUpperCase()}). Receipt #$receiptNumber. Thank you! - Alogyan Academy';
  }
}
