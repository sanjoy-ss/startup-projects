import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/features/students/controllers/students_controller.dart';
import 'package:alogyan_app/features/students/data/repositories/student_repository.dart';

class FakeStudentRepository extends Fake implements StudentRepository {
  final _controller = StreamController<List<StudentItem>>.broadcast();

  @override
  Stream<List<StudentItem>> streamStudents({String? instituteId}) => _controller.stream;

  void emit(List<StudentItem> students) => _controller.add(students);
}

void main() {
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
}
