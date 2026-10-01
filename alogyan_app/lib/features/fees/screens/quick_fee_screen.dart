import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/alogyan_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../students/controllers/students_controller.dart';
import '../controllers/fee_controller.dart';

class QuickFeeScreen extends StatelessWidget {
  const QuickFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feeController = Get.put(FeeController());
    final studentsController = Get.isRegistered<StudentsController>()
        ? Get.find<StudentsController>()
        : Get.put(StudentsController());

    final amountTextController = TextEditingController(text: feeController.amount.value);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen Title
          const Text(
            'Quick Fee Collection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AlogyanColors.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select student to generate on-screen UPI QR or log cash payment',
            style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary),
          ),
          const SizedBox(height: 16),

          Obx(() {
            final students = studentsController.allStudents;
            if (students.isEmpty) {
              return AlogyanCard(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AlogyanColors.surfaceMuted,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.users, size: 36, color: AlogyanColors.textSecondary),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Students Registered',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AlogyanColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add students to your roster to collect fees, manage pending dues, and generate on-screen UPI QR codes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
              );
            }

            final current = feeController.selectedStudent.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Selector Card
                const Text('Select Student', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AlogyanColors.textSecondary)),
                const SizedBox(height: 6),
                AlogyanCard(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<StudentItem>(
                      isExpanded: true,
                      value: current != null && students.contains(current) ? current : students.first,
                      icon: const Icon(LucideIcons.chevronDown, size: 18, color: AlogyanColors.textSecondary),
                      items: students.map((s) {
                        final due = s.dueAmount;
                        return DropdownMenuItem<StudentItem>(
                          value: s,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text(s.batch, style: const TextStyle(fontSize: 11, color: AlogyanColors.textSecondary)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: due > 0 ? AlogyanColors.dangerLight : AlogyanColors.successLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  due > 0 ? 'Due: ₹$due' : 'Paid',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: due > 0 ? AlogyanColors.danger : AlogyanColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (selected) {
                        if (selected != null) {
                          feeController.selectStudent(selected);
                          amountTextController.text = feeController.amount.value;
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Amount Input
                const Text('Amount (₹)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AlogyanColors.textSecondary)),
                const SizedBox(height: 6),
                TextField(
                  controller: amountTextController,
                  keyboardType: TextInputType.number,
                  onChanged: feeController.updateAmount,
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    filled: true,
                    fillColor: AlogyanColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AlogyanColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AlogyanColors.border),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Payment Mode Selector
                const Text('Payment Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AlogyanColors.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ChoiceChip(
                      label: const Text('Dynamic UPI QR'),
                      selected: feeController.paymentMode.value == 'upi',
                      onSelected: (val) => feeController.setPaymentMode('upi'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Cash'),
                      selected: feeController.paymentMode.value == 'cash',
                      onSelected: (val) => feeController.setPaymentMode('cash'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // On-Screen Dynamic UPI QR Code
                if (feeController.paymentMode.value == 'upi') ...[
                  Center(
                    child: Container(
                      width: 220,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AlogyanColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.qr_code_2, size: 130, color: AlogyanColors.textPrimary),
                          const SizedBox(height: 8),
                          Text(
                            '₹${feeController.amount.value} for ${feeController.selectedStudent.value?.name ?? 'Student'}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Scan via GPay / PhonePe / Paytm',
                            style: TextStyle(fontSize: 11, color: AlogyanColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Submit & WhatsApp Receipt Button
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'Confirm & Send WhatsApp Receipt',
                    isLoading: feeController.isProcessing.value,
                    onPressed: feeController.confirmPayment,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
