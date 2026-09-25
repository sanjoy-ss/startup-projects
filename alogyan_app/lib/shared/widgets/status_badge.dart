import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

enum StatusBadgeType { success, warning, danger, info }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case StatusBadgeType.success:
        bg = AlogyanColors.successLight;
        fg = AlogyanColors.success;
        break;
      case StatusBadgeType.warning:
        bg = AlogyanColors.warningLight;
        fg = AlogyanColors.warning;
        break;
      case StatusBadgeType.danger:
        bg = AlogyanColors.dangerLight;
        fg = AlogyanColors.danger;
        break;
      case StatusBadgeType.info:
        bg = AlogyanColors.infoLight;
        fg = AlogyanColors.info;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
