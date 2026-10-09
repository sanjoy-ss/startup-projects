import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../../attendance/screens/quick_attendance_screen.dart';
import '../models/batch_model.dart';

class BatchAttendancePage extends StatelessWidget {
  final BatchItem batch;

  const BatchAttendancePage({
    super.key,
    required this.batch,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AlogyanColors.background,
      appBar: AppBar(
        backgroundColor: AlogyanColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, size: 20, color: AlogyanColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Batch Attendance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AlogyanColors.textPrimary,
              ),
            ),
            Text(
              batch.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AlogyanColors.textSecondary,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(color: AlogyanColors.border, height: 1.0, thickness: 1.0),
        ),
      ),
      body: const SafeArea(
        top: false,
        child: QuickAttendanceScreen(),
      ),
    );
  }
}
