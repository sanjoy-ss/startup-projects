import 'package:get/get.dart';
import '../../students/controllers/students_controller.dart';
import '../data/repositories/fee_repository.dart';

class FeeController extends GetxController {
  final FeeRepository? repository;

  final Rxn<StudentItem> selectedStudent = Rxn<StudentItem>();
  final RxString amount = '2000'.obs;
  final RxString paymentMode = 'upi'.obs; // 'upi' | 'cash'
  final RxBool isProcessing = false.obs;

  FeeController({this.repository});

  @override
  void onInit() {
    super.onInit();
    final studentsCtrl = Get.isRegistered<StudentsController>() ? Get.find<StudentsController>() : null;
    if (studentsCtrl != null && studentsCtrl.allStudents.isNotEmpty) {
      final defaultStudent = studentsCtrl.allStudents.firstWhere(
        (s) => s.dueAmount > 0,
        orElse: () => studentsCtrl.allStudents.first,
      );
      selectStudent(defaultStudent);
    }
  }

  void selectStudent(StudentItem student) {
    selectedStudent.value = student;
    amount.value = student.dueAmount > 0 ? student.dueAmount.toString() : '2000';
  }

  void setPaymentMode(String mode) {
    paymentMode.value = mode;
  }

  void updateAmount(String val) {
    amount.value = val;
  }

  Future<void> confirmPayment() async {
    final student = selectedStudent.value;
    final studentName = student?.name ?? 'Aarav Sharma';
    final studentId = student?.id ?? '1';
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
    Get.snackbar(
      'Payment Recorded',
      receiptMsg,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
}
