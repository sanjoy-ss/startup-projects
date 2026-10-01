import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:alogyan_app/core/cache/cache_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;

  setUpAll(() async {
    tempDir = Directory.systemTemp.createTempSync('hive_cache_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('CacheService initializes with zero dummy students seeded', () async {
    final cache = CacheService();
    await cache.init();

    final students = cache.getCachedStudents();
    expect(students, isEmpty, reason: 'CacheService should not seed hardcoded dummy students');
  });

  test('CacheService correctly tracks onboarding status from settings box', () async {
    final cache = CacheService();
    await cache.init();

    expect(cache.hasCompletedOnboarding(), isFalse);
    await cache.setOnboardingCompleted(true);
    expect(cache.hasCompletedOnboarding(), isTrue);
  });
}
