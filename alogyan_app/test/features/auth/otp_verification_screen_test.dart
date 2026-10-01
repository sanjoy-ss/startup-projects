import 'package:alogyan_app/core/constants/otp_mascot_data.dart';
import 'package:alogyan_app/features/auth/controllers/auth_controller.dart';
import 'package:alogyan_app/features/auth/data/auth_repository.dart';
import 'package:alogyan_app/features/auth/screens/otp_verification_screen.dart';
import 'package:alogyan_app/features/auth/widgets/otp_mascot_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'auth_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OtpMascotData & Asset Integrity', () {
    test('all 3 mascot poses have non-empty bytes and decode to valid PNG', () {
      expect(OtpMascotData.openEyesBytes.length, greaterThan(1000));
      expect(OtpMascotData.hidingEyesBytes.length, greaterThan(1000));
      expect(OtpMascotData.peekingEyesBytes.length, greaterThan(1000));

      // PNG magic number: 0x89, 0x50, 0x4E, 0x47
      expect(OtpMascotData.openEyesBytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
      expect(OtpMascotData.hidingEyesBytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
      expect(OtpMascotData.peekingEyesBytes.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    });
  });

  group('OtpMascotWidget Component Tests', () {
    testWidgets('renders open, hiding, and peeking states cleanly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OtpMascotWidget(
              state: OtpMascotState.open,
              size: 140,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(OtpMascotWidget), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);

      // Re-pump with hiding state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OtpMascotWidget(
              state: OtpMascotState.hiding,
              size: 140,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OtpMascotWidget), findsOneWidget);

      // Re-pump with peeking state
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OtpMascotWidget(
              state: OtpMascotState.peeking,
              size: 140,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(OtpMascotWidget), findsOneWidget);
    });

    testWidgets('onTap callback fires when mascot is tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OtpMascotWidget(
              state: OtpMascotState.open,
              size: 140,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(OtpMascotWidget));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('OtpVerificationScreen Integration Tests', () {
    late FakeCacheService fakeCache;
    late AuthRepository authRepo;
    late AuthController authController;

    setUp(() {
      Get.reset();
      fakeCache = FakeCacheService();
      authRepo = AuthRepository(cacheService: fakeCache);
      authController = Get.put(AuthController(authRepository: authRepo));
      authController.phoneController.text = '9876543210';
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('renders all visual elements including organic wave, mascot, 6 boxes, and verify button',
        (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: OtpVerificationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title & destination phone
      expect(find.text('Verify Mobile OTP'), findsOneWidget);
      expect(find.textContaining('9876543210'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);

      // Verify mascot is rendered
      expect(find.byType(OtpMascotWidget), findsOneWidget);

      // Verify 6 OTP digit text fields
      expect(find.byType(TextField), findsNWidgets(6));

      // Verify Test mode hint
      expect(find.textContaining('Test mode: enter any 6 digits'), findsOneWidget);

      // Verify primary action button
      expect(find.text('Verify & Open Classroom'), findsOneWidget);
    });

    testWidgets('entering digits updates text fields and switches mascot to hiding state',
        (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: OtpVerificationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);

      // Enter 5 digits sequentially
      await tester.enterText(textFields.at(0), '1');
      await tester.pump();
      await tester.enterText(textFields.at(1), '2');
      await tester.pump();
      await tester.enterText(textFields.at(2), '3');
      await tester.pump();
      await tester.enterText(textFields.at(3), '4');
      await tester.pump();
      await tester.enterText(textFields.at(4), '5');
      await tester.pump();

      // Verify text fields contain entered digits
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      // Mascot widget is in hiding state protecting privacy
      final mascot = tester.widget<OtpMascotWidget>(find.byType(OtpMascotWidget));
      expect(mascot.state, OtpMascotState.hiding);
    });

    testWidgets('pasting partial multi-digit code distributes across consecutive boxes',
        (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: OtpVerificationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final firstBox = find.byType(TextField).at(0);
      await tester.enterText(firstBox, '4321');
      await tester.pump();

      expect(find.text('4'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('tapping mascot toggles between hiding and peeking state', (tester) async {
      await tester.pumpWidget(
        const GetMaterialApp(
          home: OtpVerificationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final mascotFinder = find.byType(OtpMascotWidget);
      // Since first OTP box is autofocused, mascot initially covers eyes (hiding)
      expect(tester.widget<OtpMascotWidget>(mascotFinder).state, OtpMascotState.hiding);

      // Tap mascot -> toggles to peeking
      await tester.tap(mascotFinder);
      await tester.pump();
      expect(tester.widget<OtpMascotWidget>(mascotFinder).state, OtpMascotState.peeking);

      // Tap mascot again -> toggles back to hiding
      await tester.tap(mascotFinder);
      await tester.pump();
      expect(tester.widget<OtpMascotWidget>(mascotFinder).state, OtpMascotState.hiding);
    });
  });
}
