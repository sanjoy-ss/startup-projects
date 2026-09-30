import 'package:flutter/material.dart';
import '../constants/bottom_sheet_mascot_data.dart';

/// A delightful wrapper for modal bottom sheets where Gyan the mascot
/// peeks over and physically grips the top edge of the sheet as it slides up.
class MascotHoldingSheetWrapper extends StatelessWidget {
  final Widget child;
  final double mascotWidth;
  final double? right;
  final double? left;

  const MascotHoldingSheetWrapper({
    super.key,
    required this.child,
    this.mascotWidth = 115,
    this.right = 26,
    this.left,
  });

  @override
  Widget build(BuildContext context) {
    // 360 x 258 aspect ratio: height = width * (258 / 360) = width * 0.7167
    final mascotHeight = mascotWidth * (258 / 360);
    // Ledge is at 84.9% of height (219 / 258)
    final ledgeY = mascotHeight * (219 / 258);
    // Position mascot so its grip line aligns with the sheet top edge
    final topOffset = -ledgeY + 1.5;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Sheet content
        child,

        // Freestanding mascot holding and grabbing top edge
        Positioned(
          top: topOffset,
          right: right,
          left: left,
          width: mascotWidth,
          height: mascotHeight,
          child: IgnorePointer(
            child: Image.memory(
              BottomSheetMascot.bytes,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    );
  }
}
