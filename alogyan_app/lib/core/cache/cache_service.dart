import 'package:hive_flutter/hive_flutter.dart';

class CacheService {
  static const String studentsBoxName = 'students_box';
  static const String batchesBoxName = 'batches_box';
  static const String attendanceBoxName = 'attendance_box';
  static const String feesBoxName = 'fees_box';
  static const String syncBoxName = 'sync_actions_box';
  static const String userBoxName = 'user_box';
  static const String settingsBoxName = 'settings_box';

  late Box _studentsBox;
  late Box _batchesBox;
  late Box _attendanceBox;
  late Box _feesBox;
  late Box _syncBox;
  late Box _userBox;
  late Box _settingsBox;

  Box get studentsBox => _studentsBox;
  Box get batchesBox => _batchesBox;
  Box get attendanceBox => _attendanceBox;
  Box get feesBox => _feesBox;
  Box get syncBox => _syncBox;
  Box get userBox => _userBox;
  Box get settingsBox => _settingsBox;

  Future<void> init() async {
    _studentsBox = await Hive.openBox(studentsBoxName);
    _batchesBox = await Hive.openBox(batchesBoxName);
    _attendanceBox = await Hive.openBox(attendanceBoxName);
    _feesBox = await Hive.openBox(feesBoxName);
    _syncBox = await Hive.openBox(syncBoxName);
    _userBox = await Hive.openBox(userBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);

    // Sanitize any stale dummy student data from previous demo runs
    _sanitizeStaleDummyData();
  }

  void _sanitizeStaleDummyData() {
    final dummyIds = {'1', '2', '3', '4', '5'};
    final keysToRemove = <dynamic>[];
    for (final key in _studentsBox.keys) {
      if (dummyIds.contains(key.toString())) {
        keysToRemove.add(key);
      }
    }
    for (final k in keysToRemove) {
      _studentsBox.delete(k);
    }
  }

  List<Map<String, dynamic>> getCachedStudents() {
    final list = <Map<String, dynamic>>[];
    for (int i = 0; i < _studentsBox.length; i++) {
      final item = _studentsBox.getAt(i);
      if (item is Map) {
        list.add(Map<String, dynamic>.from(item));
      }
    }
    return list;
  }

  Future<void> cacheStudents(List<Map<String, dynamic>> list) async {
    for (final s in list) {
      await _studentsBox.put(s['id'], s);
    }
  }

  List<Map<String, dynamic>> getCachedBatches() {
    final list = <Map<String, dynamic>>[];
    for (int i = 0; i < _batchesBox.length; i++) {
      final item = _batchesBox.getAt(i);
      if (item is Map) {
        list.add(Map<String, dynamic>.from(item));
      }
    }
    return list;
  }

  Future<void> cacheBatches(List<Map<String, dynamic>> list) async {
    for (final b in list) {
      await _batchesBox.put(b['id'], b);
    }
  }

  Map<String, String>? getCachedAttendance(String batchId, String date) {
    final key = '${batchId}_$date';
    final data = _attendanceBox.get(key);
    if (data is Map) {
      return Map<String, String>.from(data);
    }
    return null;
  }

  Future<void> cacheAttendance(String batchId, String date, Map<String, String> records) async {
    final key = '${batchId}_$date';
    await _attendanceBox.put(key, records);
  }

  Future<void> cacheFeePayment(Map<String, dynamic> feeData) async {
    await _feesBox.put(feeData['id'] ?? DateTime.now().toIso8601String(), feeData);
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _userBox.put('active_user', userData);
  }

  Map<String, dynamic>? getCachedUser() {
    final data = _userBox.get('active_user');
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  Future<void> clearUser() async {
    await _userBox.delete('active_user');
  }

  bool hasCompletedOnboarding() {
    return _settingsBox.get('completed_onboarding', defaultValue: false) as bool? ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await _settingsBox.put('completed_onboarding', value);
  }
}
