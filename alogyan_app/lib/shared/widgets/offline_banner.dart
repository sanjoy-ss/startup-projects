import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class OfflineBanner extends StatelessWidget {
  final int pendingCount;
  final VoidCallback? onSyncNow;

  const OfflineBanner({
    super.key,
    required this.pendingCount,
    this.onSyncNow,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingCount <= 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AlogyanColors.warningLight,
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 18, color: AlogyanColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$pendingCount actions pending sync (saved locally)',
              style: const TextStyle(
                color: AlogyanColors.warning,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onSyncNow != null)
            TextButton(
              onPressed: onSyncNow,
              child: const Text('Sync Now', style: TextStyle(color: AlogyanColors.warning)),
            ),
        ],
      ),
    );
  }
}
