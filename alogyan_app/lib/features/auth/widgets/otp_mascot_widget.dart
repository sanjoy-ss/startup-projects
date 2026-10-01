import 'package:flutter/material.dart';

import '../../../core/constants/otp_mascot_data.dart';

/// Interactive visual states for Gyan the educator mascot on the OTP screen.
enum OtpMascotState {
  /// Open eyes, standing attentively and welcoming the user.
  open,

  /// Covering both eyes with wings/hands for privacy and confidentiality.
  hiding,

  /// Peeking with one eye when OTP code is complete or verifying.
  peeking,
}

/// An interactive, animated mascot widget that smoothly transitions between
/// Gyan opening eyes, hiding eyes behind wings, and playfully peeking.
class OtpMascotWidget extends StatelessWidget {
  final OtpMascotState state;
  final double size;
  final VoidCallback? onTap;

  const OtpMascotWidget({
    super.key,
    required this.state,
    this.size = 140,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageBytes = switch (state) {
      OtpMascotState.open => OtpMascotData.openEyesBytes,
      OtpMascotState.hiding => OtpMascotData.hidingEyesBytes,
      OtpMascotState.peeking => OtpMascotData.peekingEyesBytes,
    };

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft ambient circular stage light for contrast against red wave
            Container(
              width: size * 0.85,
              height: size * 0.85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),

            // Smooth animated state switcher
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Image.memory(
                imageBytes,
                key: ValueKey<OtpMascotState>(state),
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
