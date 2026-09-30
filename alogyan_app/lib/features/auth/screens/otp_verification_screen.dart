import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../controllers/auth_controller.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _digitControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _digitControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String _getCombinedOtp() {
    return _digitControllers.map((c) => c.text).join();
  }

  void _onDigitChanged(int index, String value, AuthController controller) {
    if (value.isNotEmpty) {
      // If user pasted multi-digit text
      if (value.length > 1) {
        final digits = value.replaceAll(RegExp(r'\D'), '').split('');
        for (int i = 0; i < digits.length && (index + i) < 6; i++) {
          _digitControllers[index + i].text = digits[i];
        }
        final nextIndex = (index + digits.length).clamp(0, 5);
        _focusNodes[nextIndex].requestFocus();
      } else {
        if (index < 5) {
          _focusNodes[index + 1].requestFocus();
        } else {
          _focusNodes[index].unfocus();
        }
      }
    }

    final fullOtp = _getCombinedOtp();
    if (fullOtp.length == 6) {
      controller.verifyOtp(fullOtp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AlogyanColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AlogyanColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Icon
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AlogyanColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AlogyanColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: const Icon(
                          LucideIcons.messageSquareCode,
                          size: 30,
                          color: AlogyanColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title & Description
                    const Center(
                      child: Text(
                        'Verify Mobile OTP',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AlogyanColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Phone number display with Edit button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Code sent to ',
                          style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary),
                        ),
                        Text(
                          '+91 ${controller.phoneController.text}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AlogyanColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: const Text(
                            'Edit',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AlogyanColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // 6 OTP Digit Input Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (index) {
                        return SizedBox(
                          width: 48,
                          height: 56,
                          child: KeyboardListener(
                            focusNode: FocusNode(),
                            onKeyEvent: (event) {
                              if (event is KeyDownEvent &&
                                  event.logicalKey == LogicalKeyboardKey.backspace &&
                                  _digitControllers[index].text.isEmpty &&
                                  index > 0) {
                                _focusNodes[index - 1].requestFocus();
                                _digitControllers[index - 1].clear();
                              }
                            },
                            child: TextField(
                              controller: _digitControllers[index],
                              focusNode: _focusNodes[index],
                              autofocus: index == 0,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AlogyanColors.textPrimary,
                              ),
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                filled: true,
                                fillColor: AlogyanColors.surface,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AlogyanColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AlogyanColors.primary,
                                    width: 2.0,
                                  ),
                                ),
                              ),
                              onChanged: (val) => _onDigitChanged(index, val, controller),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 12),

                    // Fast Demo hint
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AlogyanColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(LucideIcons.info, size: 14, color: AlogyanColors.textSecondary),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Test mode: enter any 6 digits (e.g. 123456) to proceed.',
                              style: TextStyle(fontSize: 11, color: AlogyanColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Error Message
                    Obx(() {
                      final error = controller.errorMessage.value;
                      if (error.isEmpty) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AlogyanColors.dangerLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AlogyanColors.danger.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.alertCircle, size: 16, color: AlogyanColors.danger),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                error,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AlogyanColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 24),

                    // Resend Timer Row
                    Obx(() {
                      final seconds = controller.resendTimer.value;
                      final canResend = controller.canResendOtp.value;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!canResend) ...[
                            const Icon(LucideIcons.timer, size: 14, color: AlogyanColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              'Resend code in 00:${seconds.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AlogyanColors.textSecondary,
                              ),
                            ),
                          ] else ...[
                            TextButton.icon(
                              onPressed: controller.resendOtp,
                              icon: const Icon(LucideIcons.refreshCw, size: 14, color: AlogyanColors.primary),
                              label: const Text(
                                'Resend Code via SMS',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AlogyanColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    }),

                    const SizedBox(height: 24),

                    // Verify Action Button
                    Obx(() {
                      final isLoading = controller.isLoading.value;
                      return SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  final otp = _getCombinedOtp();
                                  controller.verifyOtp(otp);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AlogyanColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Verifying OTP...',
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Verify & Open Classroom',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
