import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/alogyan_card.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';
import 'class_details_screen.dart';

class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    final currencyFormatter = NumberFormat('#,##,###');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Date Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Good morning, Sanjoy',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AlogyanColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Tuesday, 6 October 2026',
                    style: TextStyle(
                      fontSize: 13,
                      color: AlogyanColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AlogyanColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.calendar,
                  color: AlogyanColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Hero Upcoming Class Card
          AlogyanCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AlogyanColors.dangerLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.clock, size: 13, color: AlogyanColors.danger),
                          const SizedBox(width: 5),
                          Obx(() => Text(
                                controller.upcomingCountdown.value,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AlogyanColors.danger,
                                ),
                              )),
                        ],
                      ),
                    ),
                    Obx(() => Text(
                          controller.upcomingBatchCode.value,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AlogyanColors.textSecondary,
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 12),
                Obx(() => Text(
                      controller.upcomingClassTitle.value,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AlogyanColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    )),
                const SizedBox(height: 2),
                Obx(() => Text(
                      controller.upcomingCourseName.value,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AlogyanColors.textSecondary,
                      ),
                    )),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AlogyanColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.video, size: 15, color: AlogyanColors.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Obx(() => Text(
                                  controller.upcomingClassTime.value,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: AlogyanColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(LucideIcons.users, size: 15, color: AlogyanColors.textSecondary),
                          const SizedBox(width: 8),
                          Obx(() => Text(
                                '${controller.upcomingEnrolledCount.value} enrolled students',
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: AlogyanColors.textSecondary,
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.openJoinLiveClass,
                        icon: const Icon(LucideIcons.play, size: 16),
                        label: const Text('Start Class'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AlogyanColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          if (controller.scheduledClasses.isNotEmpty) {
                            Get.to(() => ClassDetailsScreen(classItem: controller.scheduledClasses.last));
                          }
                        },
                        icon: const Icon(LucideIcons.checkSquare, size: 16),
                        label: const Text('Class Details'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AlogyanColors.textPrimary,
                          side: const BorderSide(color: AlogyanColors.border),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Needs Attention Section
          Obx(() {
            final items = controller.needsAttentionItems;
            if (items.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Needs Attention',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AlogyanColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AlogyanColors.dangerLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${items.length} pending',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AlogyanColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AlogyanColors.surface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AlogyanColors.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: item.isCritical ? AlogyanColors.dangerLight : AlogyanColors.surfaceMuted,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                item.isCritical ? LucideIcons.alertTriangle : LucideIcons.clipboardCheck,
                                color: item.isCritical ? AlogyanColors.danger : AlogyanColors.textSecondary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: AlogyanColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.subtitle,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AlogyanColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => controller.resolveAttentionItem(item.id),
                              style: TextButton.styleFrom(
                                foregroundColor: AlogyanColors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                item.actionLabel,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                const SizedBox(height: 12),
              ],
            );
          }),

          // Quick Actions Grid (4 items)
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AlogyanColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildQuickActionItem(
                icon: LucideIcons.userCheck,
                label: 'Mark Attendance',
                isPrimary: true,
                onTap: () {
                  if (controller.todaySchedule.isNotEmpty) {
                    controller.navigateToTakeAttendance(controller.todaySchedule.first);
                  } else {
                    controller.openBatchesList();
                  }
                },
              ),
              const SizedBox(width: 8),
              _buildQuickActionItem(
                icon: LucideIcons.userPlus,
                label: 'Add Student',
                onTap: controller.openStudentsList,
              ),
              const SizedBox(width: 8),
              _buildQuickActionItem(
                icon: LucideIcons.fileText,
                label: 'Share Notes',
                onTap: controller.openMaterialsNotes,
              ),
              const SizedBox(width: 8),
              _buildQuickActionItem(
                icon: LucideIcons.indianRupee,
                label: 'Record Fee',
                onTap: controller.openFeesOverview,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Today's Classes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Classes",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AlogyanColors.textPrimary,
                ),
              ),
              Obx(() => Text(
                    '${controller.scheduledClasses.length} Scheduled',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AlogyanColors.textSecondary,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          AlogyanCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Obx(() => Column(
                  children: [
                    for (int i = 0; i < controller.scheduledClasses.length; i++) ...[
                      if (i > 0) const Divider(height: 16, color: AlogyanColors.border),
                      _buildScheduledClassRow(controller.scheduledClasses[i]),
                    ]
                  ],
                )),
          ),
          const SizedBox(height: 20),

          // Agartala Center Overview Grid (2x2)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Agartala Center Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AlogyanColors.textPrimary,
                ),
              ),
              Text(
                'October',
                style: TextStyle(
                  fontSize: 12,
                  color: AlogyanColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Active Students',
                  valueWidget: Obx(() => Text(
                        '${controller.activeStudentsCount.value}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AlogyanColors.textPrimary,
                        ),
                      )),
                  caption: 'Across 3 Batches',
                  captionColor: AlogyanColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Batches Teaching',
                  valueWidget: Obx(() => Text(
                        '${controller.batchesTeachingCount.value}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AlogyanColors.textPrimary,
                        ),
                      )),
                  caption: 'CB, ME, FL',
                  captionColor: AlogyanColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Fees Collected',
                  valueWidget: Obx(() => Text(
                        '₹${currencyFormatter.format(controller.feesCollectedThisMonth.value)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AlogyanColors.textPrimary,
                        ),
                      )),
                  caption: 'This month',
                  captionColor: AlogyanColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricTile(
                  label: 'Outstanding',
                  valueWidget: Obx(() => Text(
                        '₹${currencyFormatter.format(controller.outstandingFees.value)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AlogyanColors.primary,
                        ),
                      )),
                  caption: '${controller.studentsDueCount.value} students due',
                  captionColor: AlogyanColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: AlogyanColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AlogyanColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isPrimary ? AlogyanColors.primaryLight : AlogyanColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? AlogyanColors.primary : AlogyanColors.textSecondary,
                  size: 19,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AlogyanColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScheduledClassRow(ScheduledClassItem item) {
    return InkWell(
      onTap: () => Get.to(() => ClassDetailsScreen(classItem: item)),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 3.5,
              height: 48,
              decoration: BoxDecoration(
                color: item.isNextUp ? AlogyanColors.primary : AlogyanColors.success,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.timeRange,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: AlogyanColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AlogyanColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.location,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AlogyanColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: item.isNextUp ? AlogyanColors.primaryLight : AlogyanColors.successLight,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    item.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: item.isNextUp ? AlogyanColors.primary : AlogyanColors.success,
                    ),
                  ),
                ),
                if (item.attendanceRecord != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.attendanceRecord!,
                    style: TextStyle(
                      fontSize: 11,
                      color: item.attendanceRecord == 'No record'
                          ? AlogyanColors.danger
                          : AlogyanColors.textSecondary,
                      fontWeight: item.attendanceRecord == 'No record' ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required Widget valueWidget,
    required String caption,
    required Color captionColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AlogyanColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AlogyanColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AlogyanColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          valueWidget,
          const SizedBox(height: 3),
          Text(
            caption,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: captionColor,
            ),
          ),
        ],
      ),
    );
  }
}
