import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/cache/cache_service.dart';
import '../../controllers/students_controller.dart';

class StudentRepository {
  final CacheService cacheService;
  final FirebaseFirestore? firestore;

  StudentRepository({
    required this.cacheService,
    this.firestore,
  });

  /// Real-time stream of students combining Firestore snapshots with local Cache fallback
  Stream<List<StudentItem>> streamStudents() {
    // 1. Get initial cached list from Hive (0ms load)
    final cachedData = cacheService.getCachedStudents();
    final initialList = cachedData.map((map) {
      return StudentItem(
        id: map['id'] as String,
        name: map['name'] as String,
        batch: map['batch'] as String,
        phone: map['phone'] as String,
        dueAmount: (map['dueAmount'] as int?) ?? 0,
      );
    }).toList();

    // Controller that immediately emits cached data, then connects to Firestore stream
    final controller = StreamController<List<StudentItem>>.broadcast();
    controller.add(initialList);

    // If Firestore is available, stream real-time updates
    try {
      final db = firestore ?? FirebaseFirestore.instance;
      db.collection('students').snapshots().listen(
        (snapshot) {
          if (snapshot.docs.isNotEmpty) {
            final liveStudents = snapshot.docs.map((doc) {
              final data = doc.data();
              return StudentItem(
                id: doc.id,
                name: (data['name'] as String?) ?? 'Unnamed',
                batch: (data['batch'] as String?) ?? 'General',
                phone: (data['phone'] as String?) ?? '',
                dueAmount: (data['dueAmount'] as int?) ?? 0,
              );
            }).toList();

            // Cache updated list in Hive
            cacheService.cacheStudents(liveStudents.map((s) => {
              'id': s.id,
              'name': s.name,
              'batch': s.batch,
              'phone': s.phone,
              'dueAmount': s.dueAmount,
            }).toList());

            controller.add(liveStudents);
          }
        },
        onError: (error) {
          // Keep serving cached stream on Firestore permission / network error
        },
      );
    } catch (_) {
      // Offline fallback mode
    }

    return controller.stream;
  }
}
