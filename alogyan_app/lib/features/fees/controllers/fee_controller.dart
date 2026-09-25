import 'package:get/get.dart';
import '../data/repositories/fee_repository.dart';

class FeeController extends GetxController {
  final FeeRepository? repository;

  final RxString amount = '2000'.obs;
  final RxString paymentMode = 'upi'.obs; // 'upi' | 'cash'
  final RxString studentName = 'Aarav Sharma (Class 10 Physics)'.obs;
  final RxBool isProcessing = false.obs;

  FeeController({this.repository});

  void setPaymentMode(String mode) {
    paymentMode.value = mode;
  }

  void updateAmount(String val) {
    amount.value = val;
  }

  Future<void> confirmPayment() async {
    isProcessing.value = true;
    final repo = repository ?? (Get.isRegistered<FeeRepository>() ? Get.find<FeeRepository>() : null);

    String receiptMsg = 'Payment recorded and queued.';
    if (repo != null) {
      receiptMsg = await repo.recordPayment(
        studentName: studentName.value,
        amount: amount.value,
        paymentMode: paymentMode.value,
      );
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
