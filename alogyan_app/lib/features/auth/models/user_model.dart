class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // 'owner' | 'teacher' | 'branch_manager' | 'accountant'
  final String instituteId;
  final String instituteName;
  final List<String> branchIds;
  final String activeBranchId;
  final String activeBranchName;
  final List<String> assignedBatchIds;
  final String designation;
  final String subject;
  final String? photoUrl;
  final String status; // 'active' | 'suspended'
  final DateTime? lastLoginAt;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.instituteId,
    required this.instituteName,
    this.branchIds = const [],
    required this.activeBranchId,
    required this.activeBranchName,
    this.assignedBatchIds = const [],
    required this.designation,
    required this.subject,
    this.photoUrl,
    this.status = 'active',
    this.lastLoginAt,
    this.createdAt,
  });

  bool get isOwner => role == 'owner';
  bool get isTeacher => role == 'teacher';
  bool get isBranchManager => role == 'branch_manager';

  String get initials {
    if (name.trim().isEmpty) return 'A';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  String get roleDisplay {
    switch (role) {
      case 'owner':
        return 'DIRECTOR / OWNER';
      case 'teacher':
        return 'FACULTY';
      case 'branch_manager':
        return 'BRANCH HEAD';
      case 'accountant':
        return 'ACCOUNTANT';
      default:
        return role.toUpperCase();
    }
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? instituteId,
    String? instituteName,
    List<String>? branchIds,
    String? activeBranchId,
    String? activeBranchName,
    List<String>? assignedBatchIds,
    String? designation,
    String? subject,
    String? photoUrl,
    String? status,
    DateTime? lastLoginAt,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      instituteId: instituteId ?? this.instituteId,
      instituteName: instituteName ?? this.instituteName,
      branchIds: branchIds ?? this.branchIds,
      activeBranchId: activeBranchId ?? this.activeBranchId,
      activeBranchName: activeBranchName ?? this.activeBranchName,
      assignedBatchIds: assignedBatchIds ?? this.assignedBatchIds,
      designation: designation ?? this.designation,
      subject: subject ?? this.subject,
      photoUrl: photoUrl ?? this.photoUrl,
      status: status ?? this.status,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'instituteId': instituteId,
      'instituteName': instituteName,
      'branchIds': branchIds,
      'activeBranchId': activeBranchId,
      'activeBranchName': activeBranchName,
      'assignedBatchIds': assignedBatchIds,
      'designation': designation,
      'subject': subject,
      'photoUrl': photoUrl,
      'status': status,
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      name: map['name'] as String? ?? 'Educator',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: map['role'] as String? ?? 'teacher',
      instituteId: map['instituteId'] as String? ?? 'alogyan_academy',
      instituteName: map['instituteName'] as String? ?? 'Alogyan Academy',
      branchIds: (map['branchIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['main-campus'],
      activeBranchId: map['activeBranchId'] as String? ?? 'main-campus',
      activeBranchName: map['activeBranchName'] as String? ?? 'Main Campus',
      assignedBatchIds: (map['assignedBatchIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      designation: map['designation'] as String? ?? 'Faculty Member',
      subject: map['subject'] as String? ?? 'General Subjects',
      photoUrl: map['photoUrl'] as String?,
      status: map['status'] as String? ?? 'active',
      lastLoginAt: map['lastLoginAt'] != null ? DateTime.tryParse(map['lastLoginAt'].toString()) : null,
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) : null,
    );
  }
}
