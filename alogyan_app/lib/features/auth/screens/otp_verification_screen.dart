import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../controllers/auth_controller.dart';
import '../widgets/otp_mascot_widget.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _digitControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  OtpMascotState _mascotState = OtpMascotState.open;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 6; i++) {
      _focusNodes[i].addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    for (final c in _digitControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.removeListener(_handleFocusChange);
      f.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    _evaluateMascotState();
  }

  void _evaluateMascotState() {
    final fullOtp = _getCombinedOtp();
    final hasFocus = _focusNodes.any((node) => node.hasFocus);

    setState(() {
      if (fullOtp.length == 6) {
        _mascotState = OtpMascotState.peeking;
      } else if (hasFocus) {
        _mascotState = OtpMascotState.hiding;
      } else {
        _mascotState = OtpMascotState.open;
      }
    });
  }

  String _getCombinedOtp() {
    return _digitControllers.map((c) => c.text).join();
  }

  void _onDigitChanged(int index, String value, AuthController controller) {
    if (value.isNotEmpty) {
      // If user pasted multi-digit text (e.g. from SMS autofill or clipboard)
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

    _evaluateMascotState();

    final fullOtp = _getCombinedOtp();
    if (fullOtp.length == 6) {
      controller.verifyOtp(fullOtp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    final topPadding = MediaQuery.of(context).padding.top;
    final headerWaveHeight = math.max(240.0, 195.0 + topPadding);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            // 1. Organic Red Brand Wave Header at the Top (Continuation of Login Screen)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: headerWaveHeight,
              child: CustomPaint(painter: _OtpRedWaveHeaderPainter()),
            ),

            // 2. Main Interactive Viewport
            SafeArea(
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 440,
                            minHeight: math.max(
                              0.0,
                              constraints.maxHeight - 20,
                            ),
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Top Navigation & Security Badge
                                _buildTopBar(),

                                const SizedBox(height: 6),

                                // Mascot Privacy Stage (Hides eyes on focus, peeks on 6 digits)
                                Center(
                                  child: OtpMascotWidget(
                                    state: _mascotState,
                                    size: 148,
                                    onTap: () {
                                      setState(() {
                                        _mascotState =
                                            _mascotState ==
                                                OtpMascotState.hiding
                                            ? OtpMascotState.peeking
                                            : OtpMascotState.hiding;
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Title, Destination Info & Edit Phone Action
                                _buildHeaderDetails(controller),

                                const SizedBox(height: 28),

                                // 6 Minimal OTP Digit Input Boxes
                                _buildOtpInputRow(controller),

                                const SizedBox(height: 12),

                                // Test Mode Helper Pill
                                _buildTestModePill(),

                                // Dynamic Error Message Banner
                                Obx(() {
                                  final error = controller.errorMessage.value;
                                  if (error.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return _buildErrorBanner(error);
                                }),

                                const SizedBox(height: 14),

                                // Resend Timer Row
                                Obx(() => _buildResendRow(controller)),

                                const SizedBox(height: 8),

                                // Primary Action Button
                                Obx(() => _buildVerifyButton(controller)),

                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Top Bar with minimal frosted Back button and Security Badge
  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Frosted Glass Back Button
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: const Center(
              child: Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
            ),
          ),
        ),

        // Minimal Secure Badge
      ],
    );
  }

  /// Title, Subtitle, and Phone Edit Row
  Widget _buildHeaderDetails(AuthController controller) {
    final rawPhone = controller.phoneController.text.trim();
    final formattedPhone = rawPhone.isEmpty ? '98765 43210' : '+91 $rawPhone';

    return Column(
      children: [
        const Text(
          'Verify Mobile OTP',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: AlogyanColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            const Text(
              'Code sent to ',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                color: AlogyanColors.textSecondary,
              ),
            ),
            Text(
              formattedPhone,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AlogyanColors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AlogyanColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AlogyanColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 6 Minimal OTP Digit Boxes with custom focus, paste, and backspace jumps
  Widget _buildOtpInputRow(AuthController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        final isFocused = _focusNodes[index].hasFocus;
        final hasValue = _digitControllers[index].text.isNotEmpty;

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
                _evaluateMascotState();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: hasValue
                    ? Colors.white
                    : (isFocused ? Colors.white : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(14),
                boxShadow: isFocused
                    ? [
                        BoxShadow(
                          color: AlogyanColors.primary.withValues(alpha: 0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: TextField(
                controller: _digitControllers[index],
                focusNode: _focusNodes[index],
                autofocus: index == 0,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AlogyanColors.textPrimary,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  filled: true,
                  fillColor: Colors.transparent,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: hasValue
                          ? AlogyanColors.primary.withValues(alpha: 0.40)
                          : const Color(0xFFE2E8F0),
                      width: hasValue ? 1.8 : 1.4,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AlogyanColors.primary,
                      width: 2.2,
                    ),
                  ),
                ),
                onChanged: (val) => _onDigitChanged(index, val, controller),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// Compact, professional Test Mode Hint
  Widget _buildTestModePill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AlogyanColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AlogyanColors.border.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      child: Row(
        children: const [
          Icon(LucideIcons.info, size: 14, color: AlogyanColors.textSecondary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Test mode: enter any 6 digits (e.g. 123456) to verify.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: AlogyanColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Error Message Banner
  Widget _buildErrorBanner(String error) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AlogyanColors.dangerLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AlogyanColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.alertCircle,
            size: 16,
            color: AlogyanColors.danger,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AlogyanColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Resend Code Row with Live Countdown
  Widget _buildResendRow(AuthController controller) {
    final seconds = controller.resendTimer.value;
    final canResend = controller.canResendOtp.value;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!canResend) ...[
          const Icon(
            LucideIcons.timer,
            size: 15,
            color: AlogyanColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            'Resend code in 00:${seconds.toString().padLeft(2, '0')}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AlogyanColors.textSecondary,
            ),
          ),
        ] else ...[
          TextButton.icon(
            onPressed: () {
              controller.resendOtp();
              _evaluateMascotState();
            },
            icon: const Icon(
              LucideIcons.refreshCw,
              size: 15,
              color: AlogyanColors.primary,
            ),
            label: const Text(
              'Resend Code via SMS',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AlogyanColors.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Primary Verification Button
  Widget _buildVerifyButton(AuthController controller) {
    final isLoading = controller.isLoading.value;
    return SizedBox(
      height: 52,
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
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
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Text(
                'Verify & Open Classroom',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
      ),
    );
  }
}

/// Organic Red Brand Wave Header Painter for the OTP screen
class _OtpRedWaveHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Vibrant Alogyan Brand Red Linear Gradient
    final wavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFE53935), // Alogyan vibrant red
          Color(0xFFB71C1C), // Deep crimson
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    // 2. Smooth G1-Continuous Cubic Wave Parameters
    final y0 = size.height * 0.82;
    final c1x = size.width * 0.25;
    final c1y = size.height * 0.94;

    final xm = size.width * 0.52;
    final ym = size.height * 0.86;

    final tanDx = size.width * 0.16;
    final tanDy = -size.height * 0.030;

    final c4x = size.width * 0.82;
    final c4y = size.height * 0.79;
    final yEnd = size.height * 0.88;

    final waveLine = Path()
      ..moveTo(0, y0)
      ..cubicTo(c1x, c1y, xm - tanDx, ym - tanDy, xm, ym)
      ..cubicTo(xm + tanDx, ym + tanDy, c4x, c4y, size.width, yEnd);

    final filledPath = Path.from(waveLine)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(filledPath, wavePaint);

    // 3. Dual-Layer Luminous Shimmer Lines
    final glowShimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.50),
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(waveLine, glowShimmerPaint);

    final coreShimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.75),
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.75),
          Colors.white.withValues(alpha: 0.15),
        ],
        stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(waveLine, coreShimmerPaint);

    // 4. Mascot Stage Ambient Halo
    final mascotStage = Offset(size.width * 0.50, size.height * 0.55);
    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.24),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: mascotStage, radius: size.width * 0.40),
          );
    canvas.drawCircle(mascotStage, size.width * 0.40, glowPaint);

    // Subtle concentric orbits
    final orbit1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(mascotStage, 60, orbit1);

    final orbit2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(mascotStage, 98, orbit2);

    // 5. Floating Micro-Sparkles
    _drawSparkle(
      canvas,
      Offset(size.width * 0.15, size.height * 0.28),
      4.5,
      0.50,
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.82, size.height * 0.22),
      4.2,
      0.45,
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.88, size.height * 0.42),
      3.8,
      0.40,
    );
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, double alpha) {
    if (alpha <= 0.0) return;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size);
    path.close();
    canvas.drawPath(path, paint);

    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: (alpha * 1.5).clamp(0.0, 1.0));
    canvas.drawCircle(center, size * 0.26, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
