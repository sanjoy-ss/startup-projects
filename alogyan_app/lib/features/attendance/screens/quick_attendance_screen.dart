import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/alogyan_card.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../batches/models/batch_model.dart';
import '../controllers/attendance_controller.dart';

class QuickAttendanceScreen extends StatelessWidget {
  const QuickAttendanceScreen({super.key});

  void _showBatchDetailsSheet(BuildContext context, BatchItem batch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: AlogyanColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AlogyanColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      batch.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AlogyanColors.textPrimary,
                      ),
                    ),
                  ),
                  StatusBadge(label: batch.status, type: batch.statusType),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Subject: ${batch.subject}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AlogyanColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: AlogyanColors.border, height: 1),
              const SizedBox(height: 16),
              _buildDetailRow(
                icon: LucideIcons.clock,
                label: 'Class Schedule',
                value: batch.timing,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                icon: LucideIcons.mapPin,
                label: 'Classroom / Mode',
                value: batch.roomOrMeet,
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                icon: LucideIcons.users,
                label: 'Roster Capacity',
                value: batch.capacity > 0
                    ? '${batch.enrolledCount} enrolled (Max ${batch.capacity} seats)'
                    : '${batch.enrolledCount} enrolled students',
              ),
              if (batch.meetLink != null && batch.meetLink!.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AlogyanColors.primary,
                      side: const BorderSide(color: AlogyanColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(LucideIcons.video, size: 16),
                    label: const Text('Open Online Class Link'),
                    onPressed: () async {
                      final uri = Uri.parse(batch.meetLink!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AlogyanColors.surfaceMuted,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AlogyanColors.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AlogyanColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AlogyanColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttendanceController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal Batch Selector Chips
        Obx(() {
          final batches = controller.availableBatches;
          if (batches.isEmpty) return const SizedBox.shrink();

          return Container(
            height: 44,
            margin: const EdgeInsets.only(top: 8, bottom: 4),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: batches.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final batch = batches[index];
                final isSelected = controller.selectedBatch.value?.id == batch.id;

                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(batch.name),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.25)
                              : AlogyanColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${batch.enrolledCount}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : AlogyanColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  selectedColor: AlogyanColors.primary,
                  backgroundColor: AlogyanColors.surface,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AlogyanColors.textPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected
                          ? AlogyanColors.primary
                          : AlogyanColors.border,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectBatch(batch);
                    }
                  },
                );
              },
            ),
          );
        }),

        // Batch Details Summary Card
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Obx(() {
            final batch = controller.selectedBatch.value;
            final title = batch?.name ?? 'Class 10 - Physics Batch';
            final timing = batch?.timing ?? '04:00 PM - 05:30 PM';
            final room = batch?.roomOrMeet ?? 'Main Hall';
            final enrolled = batch?.enrolledCount ?? controller.totalCount;

            return AlogyanCard(
              onTap: batch != null
                  ? () => _showBatchDetailsSheet(context, batch)
                  : null,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AlogyanColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (batch != null) ...[
                              const SizedBox(width: 6),
                              StatusBadge(
                                  label: batch.status,
                                  type: batch.statusType),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(LucideIcons.clock,
                                size: 13, color: AlogyanColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              timing,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AlogyanColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(LucideIcons.mapPin,
                                size: 13, color: AlogyanColors.textMuted),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                room,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AlogyanColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(LucideIcons.users,
                                size: 13, color: AlogyanColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              '$enrolled Enrolled',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AlogyanColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (batch != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AlogyanColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AlogyanColors.border),
                      ),
                      child: const Icon(LucideIcons.info,
                          size: 16, color: AlogyanColors.primary),
                    ),
                ],
              ),
            );
          }),
        ),

        // Live Attendance Action Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AlogyanColors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AlogyanColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                    '${controller.presentCount} / ${controller.totalCount} Present',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AlogyanColors.textPrimary,
                    ),
                  )),
              Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AlogyanColors.danger,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: controller.markAllAbsent,
                    child: const Text('All Absent',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                  const SizedBox(width: 6),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AlogyanColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(LucideIcons.checkCheck, size: 15),
                    onPressed: controller.markAllPresent,
                    label: const Text('Mark All Present',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Student Roster
        Expanded(
          child: Obx(() {
            final students = controller.students;
            if (students.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AlogyanColors.surfaceMuted,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.userCheck,
                          size: 36,
                          color: AlogyanColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No Students in Roster',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AlogyanColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Once students are enrolled in this batch via the Alogyan CMS, they will appear here for 10-second rapid attendance.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AlogyanColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: students.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AlogyanColors.border),
              itemBuilder: (context, index) {
                final student = students[index];
                final status = student.status;

                Color badgeBg = AlogyanColors.successLight;
                Color badgeFg = AlogyanColors.success;
                if (status == 'absent') {
                  badgeBg = AlogyanColors.dangerLight;
                  badgeFg = AlogyanColors.danger;
                } else if (status == 'late') {
                  badgeBg = AlogyanColors.warningLight;
                  badgeFg = AlogyanColors.warning;
                }

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  leading: CircleAvatar(
                    backgroundColor: AlogyanColors.surfaceMuted,
                    child: Text(
                      student.name.isNotEmpty
                          ? student.name.substring(0, 1).toUpperCase()
                          : 'S',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AlogyanColors.textPrimary),
                    ),
                  ),
                  title: Text(student.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('Roll #${student.roll}',
                      style: const TextStyle(
                          fontSize: 12, color: AlogyanColors.textSecondary)),
                  trailing: InkWell(
                    onTap: () => controller.toggleStatus(index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 90,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                            color: badgeFg,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),

        // Bottom Submission Bar
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: Obx(() => PrimaryButton(
                    text:
                        'Submit Attendance (${controller.presentCount}/${controller.totalCount})',
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.submitAttendance,
                  )),
            ),
          ),
        ),
      ],
    );
  }
}
