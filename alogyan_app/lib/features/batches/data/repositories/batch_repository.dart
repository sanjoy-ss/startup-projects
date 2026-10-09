import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/cache/cache_service.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../models/batch_model.dart';

class BatchRepository {
  final CacheService cacheService;
  final FirebaseFirestore? firestore;

  BatchRepository({required this.cacheService, this.firestore});

  /// Real-time stream of batches scoped to active tenant/institute
  Stream<List<BatchItem>> streamBatches({String? instituteId}) {
    // 1. Initial cached value from Hive for 0ms offline startup
    final cached = cacheService.getCachedBatches();
    List<BatchItem> initialList = cached.map((map) {
      return BatchItem.fromMap(map['id']?.toString() ?? '', map);
    }).toList();

    // If cache is empty, seed realistic coaching center batches for 0ms startup
    if (initialList.isEmpty) {
      initialList = _getDefaultBatches();
      cacheService.cacheBatches(initialList.map((b) => b.toMap()).toList());
    }

    final controller = StreamController<List<BatchItem>>.broadcast();
    controller.add(initialList);

    // 2. Real-time Firestore stream
    try {
      final db = firestore ?? FirebaseFirestore.instance;
      Query<Map<String, dynamic>> query = db.collection('batches');
      if (instituteId != null && instituteId.isNotEmpty) {
        query = query.where('instituteId', isEqualTo: instituteId);
      }

      query.snapshots().listen(
        (snapshot) {
          final liveBatches = snapshot.docs.map((doc) {
            return BatchItem.fromMap(doc.id, doc.data());
          }).toList();

          cacheService.cacheBatches(liveBatches.map((b) => b.toMap()).toList());
          controller.add(liveBatches);
        },
        onError: (e) {
          debugPrint('Notice streaming batches: $e');
        },
      );
    } catch (e) {
      debugPrint('Firestore offline fallback for batches: $e');
    }

    return controller.stream;
  }

  static List<BatchItem> _getDefaultBatches() {
    return [
      BatchItem(
        id: 'batch_cbse_10_maths',
        name: 'Class 10 CBSE • Mathematics',
        subject: 'Mathematics',
        timing: '04:30 PM - 06:00 PM • Mon, Wed, Fri',
        roomOrMeet: 'Room 101 • South Block',
        status: 'ACTIVE',
        statusType: StatusBadgeType.info,
        capacity: 30,
        studentIds: ['std_1', 'std_2', 'std_3', 'std_4', 'std_5'],
      ),
      BatchItem(
        id: 'batch_neet_physics',
        name: 'NEET Droppers • Physics Mastery',
        subject: 'Physics',
        timing: '10:00 AM - 11:30 AM • Daily',
        roomOrMeet: 'Online (Google Meet)',
        status: 'NEXT CLASS',
        statusType: StatusBadgeType.warning,
        meetLink: 'https://meet.google.com/xyz-tuip-abc',
        capacity: 45,
        studentIds: ['std_1', 'std_3', 'std_6', 'std_7'],
      ),
      BatchItem(
        id: 'batch_isc_12_chem',
        name: 'Class 12 ISC • Organic Chemistry',
        subject: 'Chemistry',
        timing: '06:15 PM - 07:45 PM • Tue, Thu, Sat',
        roomOrMeet: 'Science Lab Hall A',
        status: 'ACTIVE',
        statusType: StatusBadgeType.info,
        capacity: 25,
        studentIds: ['std_2', 'std_4', 'std_8'],
      ),
      BatchItem(
        id: 'batch_jee_adv_maths',
        name: 'IIT-JEE Advanced • Calculus & Vectors',
        subject: 'Mathematics',
        timing: '08:00 AM - 09:45 AM • Sat, Sun',
        roomOrMeet: 'Room 204 • North Wing',
        status: 'ACTIVE',
        statusType: StatusBadgeType.info,
        capacity: 20,
        studentIds: ['std_1', 'std_2', 'std_5', 'std_9'],
      ),
      BatchItem(
        id: 'batch_icse_9_bio',
        name: 'Class 9 ICSE • Biology & Genetics',
        subject: 'Biology',
        timing: '03:00 PM - 04:15 PM • Mon, Wed',
        roomOrMeet: 'Online (Google Meet)',
        status: 'COMPLETED',
        statusType: StatusBadgeType.success,
        meetLink: 'https://meet.google.com/bio-stem-class',
        capacity: 35,
        studentIds: ['std_3', 'std_5', 'std_10'],
      ),
    ];
  }
}
