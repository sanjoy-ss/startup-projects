import 'package:uuid/uuid.dart';

class SyncAction {
  final String id;
  final String type;
  final String endpoint;
  final String method;
  final Map<String, dynamic> payload;
  final int createdAt;
  int retryCount;
  String status;

  SyncAction({
    String? id,
    required this.type,
    required this.endpoint,
    this.method = 'POST',
    required this.payload,
    int? createdAt,
    this.retryCount = 0,
    this.status = 'pending',
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'endpoint': endpoint,
      'method': method,
      'payload': payload,
      'createdAt': createdAt,
      'retryCount': retryCount,
      'status': status,
    };
  }

  factory SyncAction.fromMap(Map<dynamic, dynamic> map) {
    return SyncAction(
      id: map['id'] as String,
      type: map['type'] as String,
      endpoint: map['endpoint'] as String,
      method: (map['method'] as String?) ?? 'POST',
      payload: Map<String, dynamic>.from(map['payload'] as Map),
      createdAt: map['createdAt'] as int,
      retryCount: (map['retryCount'] as int?) ?? 0,
      status: (map['status'] as String?) ?? 'pending',
    );
  }
}
