import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../../../shared/widgets/alogyan_card.dart';
import '../controllers/dashboard_controller.dart';
import '../models/dashboard_models.dart';

class ExecutiveDashboardView extends StatelessWidget {
  const ExecutiveDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Campus Status & Date Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AlogyanColors.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AlogyanColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TUESDAY, 06 OCT 2026',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: AlogyanColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(
                          () => Text(
                            controller.campusName.value,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: AlogyanColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AlogyanColors.successLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AlogyanColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Obx(
                            () => Text(
                              controller.campusStatus.value,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AlogyanColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Obx(
                  () => Text(
                    controller.campusDepartment.value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AlogyanColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Status info & sync
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AlogyanColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AlogyanColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            LucideIcons.checkCircle,
                            size: 16,
                            color: AlogyanColors.success,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '3 Batches in Progress • All Systems Nominal',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AlogyanColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => Text(
                          controller.syncStatus.value,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AlogyanColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Segment filter (Today, This Week, Oct 2026)
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: AlogyanColors.border,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Obx(
                    () => Row(
                      children: [
                        _buildPeriodFilterTab(
                          title: 'Today',
                          isSelected:
                              controller.executivePeriod.value == 'Today',
                          onTap: () => controller.setExecutivePeriod('Today'),
                        ),
                        _buildPeriodFilterTab(
                          title: 'This Week',
                          isSelected:
                              controller.executivePeriod.value == 'This Week',
                          onTap: () =>
                              controller.setExecutivePeriod('This Week'),
                        ),
                        _buildPeriodFilterTab(
                          title: 'Oct 2026',
                          isSelected:
                              controller.executivePeriod.value == 'Oct 2026',
                          onTap: () =>
                              controller.setExecutivePeriod('Oct 2026'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Campus Vitals (4 grid tiles)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Campus Vitals',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AlogyanColors.textPrimary,
                ),
              ),
              Text(
                'Live Snapshot',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AlogyanColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildVitalTile(
                  title: 'Active Students',
                  icon: LucideIcons.users,
                  valueWidget: Obx(
                    () => RichText(
                      text: TextSpan(
                        text: controller.executiveActiveStudents.value
                            .split('/')
                            .first,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AlogyanColors.textPrimary,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '/${controller.executiveActiveStudents.value.split('/').last}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: AlogyanColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  footerWidget: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: AlogyanColors.successLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '+3 this mo',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AlogyanColors.success,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Obx(
                        () => Text(
                          controller.executiveCapacityRate.value,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AlogyanColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildVitalTile(
                  title: 'Today Attendance',
                  icon: LucideIcons.userCheck,
                  iconColor: AlogyanColors.success,
                  valueWidget: Obx(
                    () => Text(
                      controller.executiveAttendanceRate.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AlogyanColors.success,
                      ),
                    ),
                  ),
                  footerWidget: Row(
                    children: [
                      const Icon(
                        LucideIcons.trendingUp,
                        size: 13,
                        color: AlogyanColors.success,
                      ),
                      const SizedBox(width: 3),
                      Obx(
                        () => Text(
                          controller.executiveAttendanceTrend.value,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AlogyanColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildVitalTile(
                  title: "Today's Lectures",
                  icon: LucideIcons.clock,
                  iconColor: AlogyanColors.primary,
                  valueWidget: Obx(
                    () => RichText(
                      text: TextSpan(
                        text: controller.executiveLecturesCount.value
                            .split('/')
                            .first,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AlogyanColors.textPrimary,
                        ),
                        children: [
                          TextSpan(
                            text:
                                '/${controller.executiveLecturesCount.value.split('/').last}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                              color: AlogyanColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  footerWidget: Obx(
                    () => Text(
                      controller.executiveNextLecture.value,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AlogyanColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildVitalTile(
                  title: 'Fee Realization',
                  icon: LucideIcons.wallet,
                  valueWidget: Obx(
                    () => Text(
                      controller.executiveFeeRealizationRate.value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AlogyanColors.textPrimary,
                      ),
                    ),
                  ),
                  footerWidget: Obx(
                    () => Text(
                      controller.executiveFeeCollectedSummary.value,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AlogyanColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Class in Waiting Hero Dock
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AlogyanColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            LucideIcons.video,
                            size: 12,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'STARTING IN 10 MINS',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        LucideIcons.cast,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Flutter Layouts & Responsive UI',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Obx(
                  () => Text(
                    'Batch FL-01 • ${controller.lobbyWaitingStudents.value} students in lobby waiting',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: controller.openJoinLiveClass,
                        icon: const Icon(LucideIcons.play, size: 16),
                        label: const Text('Start Lecture Room'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AlogyanColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        onPressed: controller.openBatchesList,
                        icon: const Icon(
                          LucideIcons.badgeCheck,
                          color: Colors.white,
                          size: 20,
                        ),
                        tooltip: 'Class roster',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Weekly Attendance Trend Chart Card
          AlogyanCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Weekly Attendance Trend',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AlogyanColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Target Benchmark: 90.0% Minimum',
                          style: TextStyle(
                            fontSize: 12,
                            color: AlogyanColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AlogyanColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Oct 01 - Oct 06',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AlogyanColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Interactive Column Chart Widget
                SizedBox(
                  height: 120,
                  child: Stack(
                    children: [
                      // Target 90% benchmark dotted line
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 25,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AlogyanColors.border,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: AlogyanColors.surface,
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: AlogyanColors.border),
                              ),
                              child: const Text(
                                'Target 90%',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AlogyanColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Bars
                      Positioned.fill(
                        child: Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: controller.weeklyAttendanceList.map((
                              item,
                            ) {
                              return _buildAttendanceBar(item);
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AlogyanColors.success,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Peak Day: Wednesday (95.4%)',
                          style: TextStyle(
                            fontSize: 11,
                            color: AlogyanColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AlogyanColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Today Ongoing',
                          style: TextStyle(
                            fontSize: 11,
                            color: AlogyanColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Monthly Fee Realization Segmented Card
          AlogyanCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Monthly Fee Realization',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AlogyanColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Target: ₹61,700 • Agartala FL Cohorts',
                          style: TextStyle(
                            fontSize: 12,
                            color: AlogyanColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '₹45,000',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AlogyanColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Multi-segment progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 10,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 73,
                          child: Container(color: AlogyanColors.success),
                        ),
                        Expanded(
                          flex: 20,
                          child: Container(color: AlogyanColors.textSecondary),
                        ),
                        Expanded(
                          flex: 7,
                          child: Container(color: AlogyanColors.danger),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AlogyanColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '₹45.0k Realized',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AlogyanColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          '73.0% of target',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AlogyanColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AlogyanColors.textSecondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '₹12.5k Pending',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AlogyanColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'Due this week',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AlogyanColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AlogyanColors.danger,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '₹4.2k Overdue',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AlogyanColors.danger,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          '14 Guardians',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: AlogyanColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Quick Operational Tasks (4-grid)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Quick Operational Tasks',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AlogyanColors.textPrimary,
                ),
              ),
              Text(
                'Instant Action',
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
              _buildOperationalTaskTile(
                icon: LucideIcons.userCheck,
                label: 'Mark Attendance',
                iconColor: AlogyanColors.primary,
                onTap: controller.openBatchesList,
              ),
              const SizedBox(width: 8),
              _buildOperationalTaskTile(
                icon: LucideIcons.receipt,
                label: 'Record Fee',
                iconColor: AlogyanColors.success,
                onTap: controller.openFeesOverview,
              ),
              const SizedBox(width: 8),
              _buildOperationalTaskTile(
                icon: LucideIcons.uploadCloud,
                label: 'Post Notes',
                iconColor: AlogyanColors.textSecondary,
                onTap: controller.openMaterialsNotes,
              ),
              const SizedBox(width: 8),
              _buildOperationalTaskTile(
                icon: LucideIcons.megaphone,
                label: 'Send Notice',
                iconColor: AlogyanColors.textSecondary,
                onTap: () {
                  Get.snackbar(
                    'Campus Notice',
                    'Notice composer ready for Agartala batches.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Campus Activity Log (Timeline)
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPeriodFilterTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AlogyanColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? AlogyanColors.textPrimary
                  : AlogyanColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVitalTile({
    required String title,
    required IconData icon,
    Color? iconColor,
    required Widget valueWidget,
    required Widget footerWidget,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AlogyanColors.textSecondary,
                ),
              ),
              Icon(
                icon,
                size: 16,
                color: iconColor ?? AlogyanColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 6),
          valueWidget,
          const SizedBox(height: 6),
          footerWidget,
        ],
      ),
    );
  }

  Widget _buildAttendanceBar(WeeklyAttendanceData item) {
    final barHeight =
        (item.percentage - 75) * 4.0; // scale between 75% and 100%
    final color = item.isToday
        ? AlogyanColors.primary
        : (item.isPeak ? AlogyanColors.success : AlogyanColors.border);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '${item.percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: item.isPeak || item.isToday
                ? FontWeight.w700
                : FontWeight.normal,
            color: item.isToday
                ? AlogyanColors.primary
                : (item.isPeak
                      ? AlogyanColors.success
                      : AlogyanColors.textSecondary),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: barHeight.clamp(20.0, 75.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          item.day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: item.isToday ? FontWeight.w700 : FontWeight.normal,
            color: item.isToday
                ? AlogyanColors.primary
                : AlogyanColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildOperationalTaskTile({
    required IconData icon,
    required String label,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: AlogyanColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AlogyanColors.border),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AlogyanColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 18),
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

  Widget _buildActivityLogTimelineItem(
    ActivityLogItem item, {
    required bool isLast,
  }) {
    IconData icon;
    Color iconBg;
    Color iconFg;

    switch (item.category) {
      case 'lobby':
        icon = LucideIcons.doorOpen;
        iconBg = AlogyanColors.primary;
        iconFg = Colors.white;
        break;
      case 'notice':
        icon = LucideIcons.messageSquare;
        iconBg = AlogyanColors.surfaceMuted;
        iconFg = AlogyanColors.textSecondary;
        break;
      case 'material':
        icon = LucideIcons.fileText;
        iconBg = AlogyanColors.infoLight;
        iconFg = AlogyanColors.info;
        break;
      case 'payment':
        icon = LucideIcons.indianRupee;
        iconBg = AlogyanColors.successLight;
        iconFg = AlogyanColors.success;
        break;
      case 'attendance':
      default:
        icon = LucideIcons.checkCheck;
        iconBg = AlogyanColors.successLight;
        iconFg = AlogyanColors.success;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 16, color: iconFg),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                color: AlogyanColors.border,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AlogyanColors.textPrimary,
                    ),
                  ),
                  Text(
                    item.time,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AlogyanColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AlogyanColors.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AlogyanColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.badgeText,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: AlogyanColors.textSecondary,
                      ),
                    ),
                  ),
                  if (item.actionText != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      item.actionText!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AlogyanColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
              if (!isLast) const SizedBox(height: 14),
            ],
          ),
        ),
      ],
    );
  }
}
