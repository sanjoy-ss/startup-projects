import 'package:get/get.dart';
import '../../students/controllers/students_controller.dart';
import '../data/repositories/fee_repository.dart';

class FeeController extends GetxController {
  final FeeRepository? repository;

  final Rxn<StudentItem> selectedStudent = Rxn<StudentItem>();
  final RxString amount = '0'.obs;
  final RxString paymentMode = 'upi'.obs; // 'upi' | 'cash'
  final RxBool isProcessing = false.obs;

  FeeController({this.repository});

  @override
  void onInit() {
    super.onInit();
    syncWithStudents();
  }

  void syncWithStudents() {
    final studentsCtrl = Get.isRegistered<StudentsController>() ? Get.find<StudentsController>() : null;
    if (studentsCtrl != null && studentsCtrl.allStudents.isNotEmpty) {
      final defaultStudent = studentsCtrl.allStudents.firstWhereOrNull(
        (s) => s.dueAmount > 0,
      ) ?? studentsCtrl.allStudents.first;
      selectStudent(defaultStudent);
    } else {
      selectedStudent.value = null;
      amount.value = '0';
    }
  }

  void selectStudent(StudentItem? student) {
    selectedStudent.value = student;
    if (student != null) {
      amount.value = student.dueAmount > 0 ? student.dueAmount.toString() : '0';
    } else {
      amount.value = '0';
    }
  }

  void setPaymentMode(String mode) {
    paymentMode.value = mode;
  }

  void updateAmount(String val) {
    amount.value = val;
  }

  Future<void> confirmPayment() async {
    final student = selectedStudent.value;
    if (student == null) {
      if (Get.context != null) {
        Get.snackbar(
          'No Student Selected',
          'Please select a student to record fee payment.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return;
    }

    final studentName = student.name;
    final studentId = student.id;
    final paidAmountInt = int.tryParse(amount.value) ?? 0;

    isProcessing.value = true;
    final repo = repository ?? (Get.isRegistered<FeeRepository>() ? Get.find<FeeRepository>() : null);

    String receiptMsg = 'Payment recorded and queued.';
    if (repo != null) {
      receiptMsg = await repo.recordPayment(
        studentName: studentName,
        amount: amount.value,
        paymentMode: paymentMode.value,
      );
    }

    // Reactively settle student's due balance across the app
    if (Get.isRegistered<StudentsController>()) {
      Get.find<StudentsController>().settleStudentDue(studentId, paidAmountInt);
    }

    isProcessing.value = false;
    if (Get.context != null) {
      Get.snackbar(
        'Payment Recorded',
        receiptMsg,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
