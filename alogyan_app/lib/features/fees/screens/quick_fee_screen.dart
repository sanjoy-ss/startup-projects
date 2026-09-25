import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/primary_button.dart';
import '../controllers/fee_controller.dart';

class QuickFeeScreen extends StatelessWidget {
  const QuickFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeeController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Fee Collection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Student', style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary)),
            const SizedBox(height: 4),
            Obx(() => Text(
                  controller.studentName.value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
            const SizedBox(height: 16),
            const Text('Amount (₹)', style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary)),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: controller.amount.value,
              keyboardType: TextInputType.number,
              onChanged: controller.updateAmount,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Payment Mode', style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary)),
            const SizedBox(height: 8),
            Obx(() => Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Dynamic UPI QR'),
                      selected: controller.paymentMode.value == 'upi',
                      onSelected: (val) => controller.setPaymentMode('upi'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Cash'),
                      selected: controller.paymentMode.value == 'cash',
                      onSelected: (val) => controller.setPaymentMode('cash'),
                    ),
                  ],
                )),
            const SizedBox(height: 24),
            Obx(() {
              if (controller.paymentMode.value == 'upi') {
                return Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AlogyanColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.qr_code_2, size: 120, color: AlogyanColors.textPrimary),
                        Text('Scan using GPay / PhonePe', style: TextStyle(fontSize: 11, color: AlogyanColors.textSecondary)),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            SizedBox(
              width: double.infinity,
              child: Obx(() => PrimaryButton(
                    text: 'Confirm & Send WhatsApp Receipt',
                    isLoading: controller.isProcessing.value,
                    onPressed: controller.confirmPayment,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
