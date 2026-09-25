import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/shared/widgets/alogyan_card.dart';
import 'package:alogyan_app/shared/widgets/primary_button.dart';
import 'package:alogyan_app/shared/widgets/status_badge.dart';
import 'package:alogyan_app/shared/widgets/offline_banner.dart';

void main() {
  testWidgets('AlogyanCard renders child and triggers onTap', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlogyanCard(
            onTap: () => tapped = true,
            child: const Text('Card Content'),
          ),
        ),
      ),
    );

    expect(find.text('Card Content'), findsOneWidget);
    await tester.tap(find.text('Card Content'));
    expect(tapped, isTrue);
  });

  testWidgets('PrimaryButton renders text and respects minimum 48dp height', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: 'Submit Attendance',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Submit Attendance'), findsOneWidget);
    final buttonFinder = find.byType(ElevatedButton);
    final buttonSize = tester.getSize(buttonFinder);
    expect(buttonSize.height, greaterThanOrEqualTo(48.0));
  });

  testWidgets('StatusBadge displays correct label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(
            label: '28 Present',
            type: StatusBadgeType.success,
          ),
        ),
      ),
    );

    expect(find.text('28 Present'), findsOneWidget);
  });

  testWidgets('OfflineBanner displays pending sync count', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OfflineBanner(pendingCount: 3),
        ),
      ),
    );

    expect(find.textContaining('3 actions pending sync'), findsOneWidget);
  });
}
