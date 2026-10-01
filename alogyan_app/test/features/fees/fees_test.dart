import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/fees/controllers/fee_controller.dart';
import 'package:alogyan_app/features/fees/screens/quick_fee_screen.dart';
import 'package:alogyan_app/features/students/controllers/students_controller.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('FeeController initializes with amount 0 when no students exist', () {
    final feeCtrl = FeeController();
    feeCtrl.onInit();

    expect(feeCtrl.selectedStudent.value, isNull);
    expect(feeCtrl.amount.value, '0');
  });

  test('FeeController selects student with dues and sets amount', () {
    final studentsCtrl = Get.put(StudentsController());
    studentsCtrl.allStudents.assignAll([
      StudentItem(id: 's1', name: 'Alice Smith', batch: 'Batch A', phone: '+91 9876543210', dueAmount: 0),
      StudentItem(id: 's2', name: 'Bob Jones', batch: 'Batch B', phone: '+91 9876543211', dueAmount: 1500),
    ]);

    final feeCtrl = FeeController();
    feeCtrl.onInit();

    expect(feeCtrl.selectedStudent.value?.id, 's2');
    expect(feeCtrl.amount.value, '1500');
  });

  test('FeeController confirmPayment does not proceed when selectedStudent is null', () async {
    final feeCtrl = FeeController();
    feeCtrl.onInit();

    await feeCtrl.confirmPayment();
    expect(feeCtrl.isProcessing.value, isFalse);
  });

  testWidgets('QuickFeeScreen displays empty state when no students enrolled', (WidgetTester tester) async {
    final studentsCtrl = Get.put(StudentsController());
    studentsCtrl.allStudents.clear();

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(
          body: QuickFeeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No Students Registered'), findsOneWidget);
    expect(find.text('Confirm & Send WhatsApp Receipt'), findsNothing);
  });
}
