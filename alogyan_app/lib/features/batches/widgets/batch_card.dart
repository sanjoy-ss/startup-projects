import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../../../shared/widgets/alogyan_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../controllers/batches_controller.dart';
import '../models/batch_model.dart';

class BatchCard extends StatelessWidget {
  final BatchItem batch;

  const BatchCard({
    super.key,
    required this.batch,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BatchesController>();
    final effectiveStudents = controller.getEffectiveEnrolledCount(batch);
    final capacity = batch.capacity;
    final double occupancyFraction = capacity > 0
        ? (effectiveStudents / capacity).clamp(0.0, 1.0)
        : 0.65;
    final bool isNearFull = occupancyFraction >= 0.9;

    return AlogyanCard(
      padding: const EdgeInsets.all(16),
      onTap: () => controller.showRoster(batch, context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Bar: Subject Badge + Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AlogyanColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AlogyanColors.border),
                ),
                child: Text(
                  batch.subject.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    color: AlogyanColors.textSecondary,
                  ),
                ),
              ),
              StatusBadge(
                label: batch.status,
                type: batch.statusType,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 2. Batch Name
          Text(
            batch.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AlogyanColors.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),

          // 3. Timing & Schedule Pill
          Row(
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
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AlogyanColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // 4. Room or Online Link Pill
          Row(
            children: [
              Icon(
                batch.isOnline ? LucideIcons.video : LucideIcons.mapPin,
                size: 14,
                color: batch.isOnline
                    ? AlogyanColors.info
                    : AlogyanColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  batch.isOnline
                      ? 'Online Class • Google Meet'
                      : batch.roomOrMeet,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: batch.isOnline
                        ? AlogyanColors.info
                        : AlogyanColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 5. Student Enrollment & Capacity Meter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.users,
                    size: 13,
                    color: AlogyanColors.textPrimary,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '$effectiveStudents Students',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AlogyanColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                capacity > 0
                    ? '$effectiveStudents / $capacity seats (${(occupancyFraction * 100).toInt()}%)'
                    : 'Open Capacity',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isNearFull
                      ? AlogyanColors.warning
                      : AlogyanColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: occupancyFraction,
              minHeight: 5,
              backgroundColor: AlogyanColors.surfaceMuted,
              valueColor: AlwaysStoppedAnimation<Color>(
                isNearFull ? AlogyanColors.warning : AlogyanColors.primary,
              ),
            ),
          ),

          // 6. Subtle Divider
          const SizedBox(height: 14),
          const Divider(color: AlogyanColors.border, height: 1, thickness: 1),
          const SizedBox(height: 12),

          // 7. Interactive Action Bar
          Row(
            children: [
              // Primary 1-tap "Take Attendance"
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AlogyanColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(LucideIcons.userCheck, size: 16),
                  label: const Text(
                    'Take Attendance',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => controller.openAttendance(batch, context),
                ),
              ),
              const SizedBox(width: 8),

              // Roster Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AlogyanColors.textPrimary,
                  side: const BorderSide(color: AlogyanColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(LucideIcons.users, size: 15),
                label: const Text(
                  'Roster',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () => controller.showRoster(batch, context),
              ),

              // If online meet link is available
              if (batch.isOnline &&
                  batch.meetLink != null &&
                  batch.meetLink!.isNotEmpty) ...[
                const SizedBox(width: 6),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: AlogyanColors.infoLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                  ),
                  icon: const Icon(
                    LucideIcons.video,
                    size: 16,
                    color: AlogyanColors.info,
                  ),
                  tooltip: 'Join Meet Link',
                  onPressed: () => controller.openMeetLink(batch.meetLink),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
