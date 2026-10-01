import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/features/auth/data/auth_repository.dart';
import 'package:alogyan_app/core/cache/cache_service.dart';

class TestFakeCacheService extends Fake implements CacheService {
  Map<String, dynamic>? _savedUser;

  @override
  Map<String, dynamic>? getCachedUser() => _savedUser;

  @override
  Future<void> saveUser(Map<String, dynamic> userData) async {
    _savedUser = userData;
  }

  @override
  Future<void> clearUser() async {
    _savedUser = null;
  }
}

void main() {
  test('AuthRepository rejects empty email/password without falling back to demo profiles', () async {
    final fakeCache = TestFakeCacheService();
    final repo = AuthRepository(cacheService: fakeCache);

    expect(
      () => repo.loginWithEmail('', ''),
      throwsA(isA<String>()),
    );
  });

  test('AuthRepository rejects invalid phone numbers without falling back to demo', () async {
    final fakeCache = TestFakeCacheService();
    final repo = AuthRepository(cacheService: fakeCache);

    expect(
      () => repo.sendPhoneOtp('123'),
      throwsA(isA<String>()),
    );
  });
}
