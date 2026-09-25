import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/app.dart';

void main() {
  testWidgets('AlogyanApp smoke test renders Dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AlogyanApp(),
      ),
    );

    expect(find.text("Today's Schedule"), findsOneWidget);
    expect(find.text('Take Attendance'), findsOneWidget);
    expect(find.text('Collect Fee'), findsOneWidget);
  });
}
