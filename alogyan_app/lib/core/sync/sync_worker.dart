import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../api/api_client.dart';
import 'sync_service.dart';

class SyncWorker extends GetxService {
  final SyncService syncService;
  final ApiClient? apiClient;
  final Connectivity _connectivity = Connectivity();

  late StreamSubscription<List<ConnectivityResult>> _sub;
  final RxBool isOnline = true.obs;
  final RxInt pendingSyncCount = 0.obs;
  final RxBool isSyncing = false.obs;

  SyncWorker({required this.syncService, this.apiClient});

  @override
  void onInit() {
    super.onInit();
    pendingSyncCount.value = syncService.pendingCount;

    // Listen to network changes
    _sub = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
    );
    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _handleConnectivityChange(results);
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    isOnline.value = online;
    pendingSyncCount.value = syncService.pendingCount;

    if (online && syncService.pendingCount > 0 && !isSyncing.value) {
      drainQueue();
    }
  }

  void refreshPendingCount() {
    pendingSyncCount.value = syncService.pendingCount;
  }

  Future<void> drainQueue() async {
    if (isSyncing.value || !isOnline.value) return;
    isSyncing.value = true;

    try {
      final actions = syncService.getPendingActions();
      for (final action in actions) {
        if (action.retryCount >= 5) {
          // Exceeded max retries, mark failed
          action.status = 'failed';
          await syncService.enqueue(action);
          continue;
        }

        try {
          if (apiClient != null) {
            // Send mutation with idempotency header
            await apiClient!.dio.request(
              action.endpoint,
              data: action.payload,
              options: Options(
                method: action.method,
                headers: {'x-idempotency-key': action.id},
              ),
            );
          }
          // Mark successfully synced and delete from queue
          await syncService.markSynced(action.id);
        } catch (e) {
          action.retryCount++;
          action.status = 'pending';
          await syncService.enqueue(action);
          // Wait briefly before attempting next item
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    } finally {
      pendingSyncCount.value = syncService.pendingCount;
      isSyncing.value = false;
    }
  }

  @override
  void onClose() {
    _sub.cancel();
    super.onClose();
  }
}
