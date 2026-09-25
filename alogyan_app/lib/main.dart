import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/api/api_client.dart';
import 'core/cache/cache_service.dart';
import 'core/config/app_config.dart';
import 'core/config/firebase_options.dart';
import 'core/sync/sync_service.dart';
import 'core/sync/sync_worker.dart';
import 'features/attendance/data/repositories/attendance_repository.dart';
import 'features/fees/data/repositories/fee_repository.dart';
import 'features/students/data/repositories/student_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase with current platform options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // 2. Initialize Hive & Multi-Box Local Cache Service
  await Hive.initFlutter();
  final cacheService = CacheService();
  await cacheService.init();
  Get.put(cacheService);

  // 3. Initialize Offline Sync Queue & API Client
  final syncService = SyncService(cacheService.syncBox);
  Get.put(syncService);

  // Uses local Next.js CMS dev URL or direct Firestore sync mode
  final apiClient = ApiClient(
    baseUrl: AppConfig.devApiBaseUrl,
    tenantId: AppConfig.defaultTenantId,
  );
  Get.put(apiClient);

  // 4. Initialize Background Sync Worker (connectivity listener)
  final syncWorker = Get.put(
    SyncWorker(syncService: syncService, apiClient: apiClient),
  );

  // 5. Register Clean Architecture Repositories
  Get.put(StudentRepository(cacheService: cacheService));
  Get.put(AttendanceRepository(
    cacheService: cacheService,
    syncService: syncService,
    syncWorker: syncWorker,
  ));
  Get.put(FeeRepository(
    cacheService: cacheService,
    syncService: syncService,
    syncWorker: syncWorker,
  ));

  runApp(const AlogyanApp());
}
