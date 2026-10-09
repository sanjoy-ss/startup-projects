import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/cache/cache_service.dart';
import '../../controllers/students_controller.dart';

class StudentRepository {
  final CacheService cacheService;
  final FirebaseFirestore? firestore;

  StudentRepository({
    required this.cacheService,
    this.firestore,
  });

  /// Real-time stream of students scoped to the active tenant/institute
  Stream<List<StudentItem>> streamStudents({String? instituteId}) {
    // 1. Get initial cached list from Hive (0ms load)
    final cachedData = cacheService.getCachedStudents();
    final initialList = cachedData.map((map) {
      final rawBatchIds = map['batchIds'];
      final List<String> batchIds = [];
      if (rawBatchIds is List) {
        for (final b in rawBatchIds) {
          if (b != null) batchIds.add(b.toString());
        }
      }
      return StudentItem(
        id: map['id']?.toString() ?? '',
        name: (map['name'] as String?) ?? 'Unnamed',
        batch: (map['batch'] as String?) ?? 'General',
        batchIds: batchIds,
        phone: (map['phone'] as String?) ?? '',
        dueAmount: (map['dueAmount'] as int?) ?? 0,
      );
    }).toList();

    final controller = StreamController<List<StudentItem>>.broadcast();
    controller.add(initialList);

    // 2. Real-time stream from Firestore scoped by instituteId
    try {
      final db = firestore ?? FirebaseFirestore.instance;
      Query<Map<String, dynamic>> query = db.collection('students');
      if (instituteId != null && instituteId.isNotEmpty) {
        query = query.where('instituteId', isEqualTo: instituteId);
      }

      query.snapshots().listen(
        (snapshot) {
          final liveStudents = snapshot.docs.map((doc) {
            final data = doc.data();
            final rawBatchIds = data['batchIds'];
            final List<String> batchIds = [];
            if (rawBatchIds is List) {
              for (final b in rawBatchIds) {
                if (b != null) batchIds.add(b.toString());
              }
            }
            return StudentItem(
              id: doc.id,
              name: (data['name'] as String?) ?? 'Unnamed',
              batch: (data['batch'] as String?) ?? 'General',
              batchIds: batchIds,
              phone: (data['phone'] as String?) ?? '',
              dueAmount: (data['dueAmount'] as int?) ?? 0,
            );
          }).toList();

          // Cache updated list in Hive
          cacheService.cacheStudents(liveStudents.map((s) => s.toMap()).toList());
          controller.add(liveStudents);
        },
        onError: (error) {
          debugPrint('Notice streaming students: $error');
        },
      );
    } catch (e) {
      debugPrint('Firestore offline fallback for students: $e');
    }

    return controller.stream;
  }
}
