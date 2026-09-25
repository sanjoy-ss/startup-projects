import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/primary_button.dart';

class QuickFeeScreen extends StatefulWidget {
  const QuickFeeScreen({super.key});

  @override
  State<QuickFeeScreen> createState() => _QuickFeeScreenState();
}

class _QuickFeeScreenState extends State<QuickFeeScreen> {
  final TextEditingController _amountController = TextEditingController(text: '2000');
  String _paymentMode = 'upi';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const Text('Aarav Sharma (Class 10 Physics)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Amount (₹)', style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Payment Mode', style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Dynamic UPI QR'),
                  selected: _paymentMode == 'upi',
                  onSelected: (val) => setState(() => _paymentMode = 'upi'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Cash'),
                  selected: _paymentMode == 'cash',
                  onSelected: (val) => setState(() => _paymentMode = 'cash'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_paymentMode == 'upi') ...[
              Center(
                child: Container(
                  width: 200,
                  height: 200,
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
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Confirm & Send WhatsApp Receipt',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment recorded and queued to sync')),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
