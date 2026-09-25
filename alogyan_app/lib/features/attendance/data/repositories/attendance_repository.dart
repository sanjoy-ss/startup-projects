import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/cache/cache_service.dart';
import '../../../../core/sync/sync_action.dart';
import '../../../../core/sync/sync_service.dart';
import '../../../../core/sync/sync_worker.dart';

class AttendanceRepository {
  final CacheService cacheService;
  final SyncService syncService;
  final SyncWorker? syncWorker;
  final FirebaseFirestore? firestore;

  AttendanceRepository({
    required this.cacheService,
    required this.syncService,
    this.syncWorker,
    this.firestore,
  });

  /// Streams today's batch attendance records in real time
  Stream<Map<String, String>> streamAttendance(String batchId, String date) {
    final controller = StreamController<Map<String, String>>.broadcast();

    // 1. Initial cached value (0ms)
    final cached = cacheService.getCachedAttendance(batchId, date) ?? {};
    controller.add(cached);

    // 2. Real-time stream from Firestore if available
    try {
      final db = firestore ?? FirebaseFirestore.instance;
      db
          .collection('attendance')
          .doc('${batchId}_$date')
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists && snapshot.data() != null) {
          final raw = snapshot.data()!['records'];
          if (raw is Map) {
            final liveRecords = Map<String, String>.from(raw);
            cacheService.cacheAttendance(batchId, date, liveRecords);
            controller.add(liveRecords);
          }
        }
      }, onError: (_) {});
    } catch (_) {}

    return controller.stream;
  }

  /// Optimistically writes attendance locally and queues for background sync
  Future<void> saveAttendance(String batchId, String date, Map<String, String> records) async {
    // 1. Cache immediately in Hive
    await cacheService.cacheAttendance(batchId, date, records);

    // 2. Create idempotent sync action
    final action = SyncAction(
      type: 'MARK_ATTENDANCE',
      endpoint: '/api/attendance',
      payload: {
        'batchId': batchId,
        'date': date,
        'records': records,
      },
    );

    // 3. Queue into sync engine
    await syncService.enqueue(action);
    syncWorker?.refreshPendingCount();

    // 4. If online, trigger background sync
    syncWorker?.drainQueue();
  }
}
