import 'package:hive/hive.dart';
import 'sync_action.dart';

class SyncService {
  static const String boxName = 'sync_actions_box';
  final Box? _box;

  SyncService([this._box]);

  Box get box => _box ?? Hive.box(boxName);

  List<SyncAction> getPendingActions() {
    final list = <SyncAction>[];
    for (int i = 0; i < box.length; i++) {
      final item = box.getAt(i);
      if (item != null && item is Map) {
        list.add(SyncAction.fromMap(item));
      }
    }
    return list;
  }

  Future<void> enqueue(SyncAction action) async {
    await box.put(action.id, action.toMap());
  }

  Future<void> markSynced(String id) async {
    await box.delete(id);
  }

  int get pendingCount => box.length;
}
