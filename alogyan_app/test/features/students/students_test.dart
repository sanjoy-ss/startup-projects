import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:alogyan_app/features/students/controllers/students_controller.dart';
import 'package:alogyan_app/features/students/data/repositories/student_repository.dart';
import 'package:alogyan_app/features/students/widgets/student_profile_modal.dart';

class FakeStudentRepository extends Fake implements StudentRepository {
  final _controller = StreamController<List<StudentItem>>.broadcast();

  @override
  Stream<List<StudentItem>> streamStudents({String? instituteId}) => _controller.stream;

  void emit(List<StudentItem> students) => _controller.add(students);
}

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  test('StudentsController initializes empty and updates strictly from repository stream', () async {
    final fakeRepo = FakeStudentRepository();
    final controller = StudentsController(repository: fakeRepo);

    expect(controller.allStudents, isEmpty);

    controller.onInit();

    fakeRepo.emit([
      StudentItem(id: 's_01', name: 'Real Student 1', batch: 'Batch A', phone: '+919999999999', dueAmount: 1500),
    ]);
    await Future.delayed(const Duration(milliseconds: 50));

    expect(controller.allStudents.length, 1);
    expect(controller.allStudents.first.name, 'Real Student 1');
    expect(controller.totalPendingDues, 1500);
  });

  test('StudentsController updateStudentProfile modifies student details', () async {
    final controller = StudentsController();
    controller.allStudents.assignAll([
      StudentItem(
        id: 's_01',
        name: 'Arjun Das',
        batch: 'Physics 101',
        phone: '+919876543210',
        dueAmount: 2000,
      ),
    ]);

    await controller.updateStudentProfile(
      studentId: 's_01',
      name: 'Arjun K. Das',
      batch: 'Advanced Physics',
      phone: '+919111222333',
      dueAmount: 500,
    );

    final updated = controller.allStudents.first;
    expect(updated.name, 'Arjun K. Das');
    expect(updated.batch, 'Advanced Physics');
    expect(updated.phone, '+919111222333');
    expect(updated.dueAmount, 500);
  });

  testWidgets('StudentProfileModal renders student details and allows changing profile', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = Get.put(StudentsController());
    final student = StudentItem(
      id: 's_01',
      name: 'Rohan Roy',
      batch: 'Class 10 Maths',
      phone: '+919876543210',
      dueAmount: 1200,
    );
    controller.allStudents.assignAll([student]);

    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => StudentProfileModal.show(context, student),
              child: const Text('Open Profile'),
            ),
          ),
        ),
      ),
    );

    // Tap to open modal
    await tester.tap(find.text('Open Profile'));
    await tester.pumpAndSettle();

    // Verify modal displays student details
    expect(find.text('Student Profile'), findsOneWidget);
    expect(find.text('Rohan Roy'), findsWidgets);
    expect(find.text('Batch: Class 10 Maths'), findsOneWidget);
    expect(find.text('Due Balance: ₹1200'), findsOneWidget);

    // Tap "Change Profile" button
    await tester.tap(find.text('Change Profile'));
    await tester.pumpAndSettle();

    // Verify edit mode fields
    expect(find.text('Save Profile Changes'), findsOneWidget);

    // Edit Name
    final nameField = find.widgetWithText(TextField, 'Student Name');
    expect(nameField, findsOneWidget);
    await tester.enterText(nameField, 'Rohan R. Roy');

    // Tap Save Changes
    final saveButton = find.text('Save Profile Changes');
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    // Verify controller updated
    expect(controller.allStudents.first.name, 'Rohan R. Roy');

    // Allow snackbar timer to expire cleanly
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
