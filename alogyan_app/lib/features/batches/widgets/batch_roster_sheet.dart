import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../students/controllers/students_controller.dart';
import '../controllers/batches_controller.dart';
import '../models/batch_model.dart';

class BatchRosterSheet extends StatelessWidget {
  final BatchItem batch;

  const BatchRosterSheet({
    super.key,
    required this.batch,
  });

  @override
  Widget build(BuildContext context) {
    final batchesCtrl = Get.find<BatchesController>();
    final studentsCtrl = Get.isRegistered<StudentsController>()
        ? Get.find<StudentsController>()
        : null;

    final rosterStudents = batchesCtrl.getStudentsForBatch(batch);
    final effectiveCount = batchesCtrl.getEffectiveEnrolledCount(batch);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AlogyanColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AlogyanColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              batch.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AlogyanColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AlogyanColors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AlogyanColors.border,
                                    ),
                                  ),
                                  child: Text(
                                    batch.subject,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AlogyanColors.textSecondary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AlogyanColors.primaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$effectiveCount Enrolled',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AlogyanColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        label: batch.status,
                        type: batch.statusType,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Schedule details
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AlogyanColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AlogyanColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.clock,
                          size: 14,
                          color: AlogyanColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            batch.timing,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AlogyanColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          batch.isOnline
                              ? LucideIcons.video
                              : LucideIcons.mapPin,
                          size: 14,
                          color: batch.isOnline
                              ? AlogyanColors.info
                              : AlogyanColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          batch.isOnline ? 'Online' : batch.roomOrMeet,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: batch.isOnline
                                ? AlogyanColors.info
                                : AlogyanColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(color: AlogyanColors.border, height: 1),

            // Roster Section Heading
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Student Roster',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AlogyanColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${rosterStudents.isNotEmpty ? rosterStudents.length : effectiveCount} Students',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AlogyanColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Students List
            Expanded(
              child: rosterStudents.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: AlogyanColors.surfaceMuted,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                LucideIcons.users,
                                size: 24,
                                color: AlogyanColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Active Batch Roster',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AlogyanColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$effectiveCount students are registered for this batch.\nTap below to mark attendance or view classroom floor.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AlogyanColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 4,
                      ),
                      itemCount: rosterStudents.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: AlogyanColors.border, height: 1),
                      itemBuilder: (context, index) {
                        final student = rosterStudents[index];
                        final hasDue = student.dueAmount > 0;

                        // Initials for avatar
                        final parts = student.name.trim().split(' ');
                        final initials = parts.isNotEmpty
                            ? (parts.first.isNotEmpty ? parts.first[0] : '') +
                                (parts.length > 1 && parts.last.isNotEmpty
                                    ? parts.last[0]
                                    : '')
                            : 'ST';

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              // Avatar circle
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AlogyanColors.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    initials.toUpperCase(),
                                    style: const TextStyle(
                                      color: AlogyanColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Name & info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AlogyanColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        if (student.phone.isNotEmpty) ...[
                                          Text(
                                            student.phone,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AlogyanColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1,
                                          ),
                                          decoration: BoxDecoration(
                                            color: hasDue
                                                ? AlogyanColors.dangerLight
                                                : AlogyanColors.successLight,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            hasDue
                                                ? '₹${student.dueAmount} Due'
                                                : 'Fees Clear',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: hasDue
                                                  ? AlogyanColors.danger
                                                  : AlogyanColors.success,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Quick contact actions
                              if (student.phone.isNotEmpty &&
                                  studentsCtrl != null) ...[
                                IconButton(
                                  icon: const Icon(
                                    LucideIcons.messageCircle,
                                    size: 18,
                                    color: AlogyanColors.success,
                                  ),
                                  onPressed: () => studentsCtrl.sendWhatsApp(
                                    student.phone,
                                    student.name,
                                  ),
                                  tooltip: 'WhatsApp',
                                ),
                                IconButton(
                                  icon: const Icon(
                                    LucideIcons.phoneCall,
                                    size: 18,
                                    color: AlogyanColors.textSecondary,
                                  ),
                                  onPressed: () =>
                                      studentsCtrl.makeCall(student.phone),
                                  tooltip: 'Call Parent',
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Bottom Sticky Action Toolbar
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: const BoxDecoration(
                color: AlogyanColors.surface,
                border: Border(
                  top: BorderSide(color: AlogyanColors.border, width: 1.0),
                ),
              ),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: 'Take Attendance Now',
                      icon: LucideIcons.userCheck,
                      onPressed: () {
                        Navigator.of(context).pop();
                        batchesCtrl.openAttendance(batch, context);
                      },
                    ),
                  ),
                  if (batch.isOnline &&
                      batch.meetLink != null &&
                      batch.meetLink!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AlogyanColors.info,
                          side: const BorderSide(color: AlogyanColors.info),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(LucideIcons.video, size: 16),
                        label: const Text(
                          'Launch Online Class',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          batchesCtrl.openMeetLink(batch.meetLink);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
