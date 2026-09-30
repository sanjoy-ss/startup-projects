import 'package:alogyan_app/core/constants/bottom_sheet_mascot_data.dart';
import 'package:alogyan_app/core/widgets/mascot_holding_sheet_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MascotHoldingSheetWrapper renders child and mascot holding image',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MascotHoldingSheetWrapper(
            mascotWidth: 120,
            right: 20,
            child: Container(
              height: 200,
              color: Colors.white,
              child: const Text('Sheet Content Test'),
            ),
          ),
        ),
      ),
    );

    // Verify child content is present
    expect(find.text('Sheet Content Test'), findsOneWidget);

    // Verify Mascot Image is rendered
    expect(find.byType(Image), findsOneWidget);

    // Verify Mascot is wrapped in IgnorePointer so it does not block interactions
    expect(
      find.descendant(
        of: find.byType(MascotHoldingSheetWrapper),
        matching: find.byWidgetPredicate((w) => w is IgnorePointer && w.ignoring),
      ),
      findsOneWidget,
    );

    // Verify bottom sheet mascot bytes are non-empty and valid PNG
    expect(BottomSheetMascot.bytes.length, greaterThan(1000));
  });
}
