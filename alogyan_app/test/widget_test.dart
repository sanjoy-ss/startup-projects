import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/app.dart';

void main() {
  testWidgets('AlogyanApp smoke test renders BottomNavigationBar and Dashboard', (WidgetTester tester) async {
    Get.testMode = true;
    await tester.pumpWidget(const AlogyanApp());

    // Verify Dashboard content is rendered
    expect(find.text("Today's Schedule"), findsOneWidget);
    expect(find.text('Take Attendance'), findsOneWidget);
    expect(find.text('Collect Fee'), findsOneWidget);

    // Verify BottomNavigationBar tabs are present
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
    expect(find.text('Fees'), findsOneWidget);
    expect(find.text('Students'), findsOneWidget);
  });
}
