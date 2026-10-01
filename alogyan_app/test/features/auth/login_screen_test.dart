import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/auth/screens/login_screen.dart';
import 'package:alogyan_app/features/auth/controllers/auth_controller.dart';
import 'package:alogyan_app/features/auth/data/auth_repository.dart';
import 'package:alogyan_app/core/cache/cache_service.dart';

class TestMockCacheService extends Fake implements CacheService {
  @override
  Map<String, dynamic>? getCachedUser() => null;
}

void main() {
  testWidgets('LoginScreen displays real auth options without demo sheet triggers', (tester) async {
    Get.reset();
    final cacheService = TestMockCacheService();
    final authRepo = AuthRepository(cacheService: cacheService);
    Get.put(AuthController(authRepository: authRepo));

    await tester.pumpWidget(const GetMaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Email & Password'), findsOneWidget);
    expect(find.text('Demo Educator Accounts'), findsNothing);
    expect(find.text('Quick Demo Login'), findsNothing);
  });
}
