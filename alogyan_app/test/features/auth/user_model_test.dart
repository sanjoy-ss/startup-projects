import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/features/auth/models/user_model.dart';

void main() {
  test('UserModel serializes and deserializes accurately without demo profiles', () {
    const user = UserModel(
      uid: 'test_uid_123',
      name: 'Jane Doe',
      email: 'jane@example.com',
      phone: '+919876543210',
      role: 'owner',
      instituteId: 'inst_abc123',
      instituteName: 'Zenith Academy',
      branchIds: ['main-campus'],
      activeBranchId: 'main-campus',
      activeBranchName: 'Main Campus',
      designation: 'Director',
      subject: 'Physics',
    );

    final map = user.toMap();
    final restored = UserModel.fromMap(map);

    expect(restored.uid, 'test_uid_123');
    expect(restored.name, 'Jane Doe');
    expect(restored.instituteId, 'inst_abc123');
    expect(restored.initials, 'JD');
    expect(restored.isOwner, isTrue);
  });
}
