import 'package:get/get.dart';
import '../../../core/sync/sync_action.dart';
import '../../../core/sync/sync_service.dart';

class FeeController extends GetxController {
  final RxString amount = '2000'.obs;
  final RxString paymentMode = 'upi'.obs; // 'upi' | 'cash'
  final RxString studentName = 'Aarav Sharma (Class 10 Physics)'.obs;
  final RxBool isProcessing = false.obs;

  void setPaymentMode(String mode) {
    paymentMode.value = mode;
  }

  void updateAmount(String val) {
    amount.value = val;
  }

  Future<void> confirmPayment() async {
    isProcessing.value = true;

    final action = SyncAction(
      type: 'COLLECT_FEE',
      endpoint: '/api/fees',
      payload: {
        'student': studentName.value,
        'amount': amount.value,
        'mode': paymentMode.value,
      },
    );

    if (Get.isRegistered<SyncService>()) {
      await Get.find<SyncService>().enqueue(action);
    }

    isProcessing.value = false;
    Get.snackbar(
      'Payment Recorded',
      '₹${amount.value} via ${paymentMode.value.toUpperCase()} recorded and queued.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
