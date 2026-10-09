import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/alogyan_card.dart';
import '../controllers/fees_overview_controller.dart';
import '../models/dashboard_models.dart';

class FeesOverviewScreen extends StatelessWidget {
  const FeesOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<FeesOverviewController>()
        ? Get.find<FeesOverviewController>()
        : Get.put(FeesOverviewController());

    final currencyFormatter = NumberFormat('#,##,###');

    return Scaffold(
      backgroundColor: AlogyanColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Fees Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AlogyanColors.textPrimary),
            ),
            Text(
              'Alogyan Academy • Agartala',
              style: TextStyle(fontSize: 12, color: AlogyanColors.textSecondary),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AlogyanColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.downloadCloud, size: 20, color: AlogyanColors.textSecondary),
            tooltip: 'Export Fee Report',
            onPressed: () {
              Get.snackbar('Export', 'Generating monthly fee report (CSV/PDF)...');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campus Pill & Period Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AlogyanColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AlogyanColors.border),
                  ),
                  child: Row(
                    children: const [
                      Icon(LucideIcons.mapPin, size: 12, color: AlogyanColors.primary),
                      SizedBox(width: 4),
                      Text(
                        'Agartala Campus',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AlogyanColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                Obx(() => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AlogyanColors.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AlogyanColors.border),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.calendar, size: 13, color: AlogyanColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            controller.selectedPeriod.value,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AlogyanColors.textPrimary),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 12),

            // Financial KPI Metrics (3 Cards)
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    title: 'Collected',
                    icon: LucideIcons.checkCircle,
                    iconColor: AlogyanColors.success,
                    valueWidget: Obx(() => Text(
                          '₹${currencyFormatter.format(controller.totalCollected.value)}',
                          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: AlogyanColors.textPrimary),
                        )),
                    subText: Obx(() => Text('${controller.receiptsCount.value} received', style: const TextStyle(fontSize: 10.5, color: AlogyanColors.textSecondary))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Pending',
                    icon: LucideIcons.clock,
                    iconColor: AlogyanColors.textSecondary,
                    valueWidget: Obx(() => Text(
                          '₹${currencyFormatter.format(controller.totalPending.value)}',
                          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: AlogyanColors.textPrimary),
                        )),
                    subText: Obx(() => Text('${controller.pendingStudentsCount.value} students', style: const TextStyle(fontSize: 10.5, color: AlogyanColors.textSecondary))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildMetricTile(
                    title: 'Overdue',
                    icon: LucideIcons.alertCircle,
                    iconColor: AlogyanColors.primary,
                    valueWidget: Obx(() => Text(
                          '₹${currencyFormatter.format(controller.totalOverdue.value)}',
                          style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w700, color: AlogyanColors.primary),
                        )),
                    subText: Obx(() => Text('${controller.criticalOverdueCount.value} critical', style: const TextStyle(fontSize: 10.5, color: AlogyanColors.danger))),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Policy Note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AlogyanColors.surfaceMuted,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: const [
                  Icon(LucideIcons.info, size: 13, color: AlogyanColors.textSecondary),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Pending dues within grace dates are not overdue. Late fees apply after 10th.',
                      style: TextStyle(fontSize: 11, color: AlogyanColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Segmented Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                    children: [
                      _buildTabChip(
                        title: 'Outstanding',
                        count: controller.pendingStudentsCount.value,
                        isSelected: controller.selectedTab.value == 0,
                        onTap: () => controller.selectTab(0),
                      ),
                      const SizedBox(width: 6),
                      _buildTabChip(
                        title: 'Recent Collections',
                        isSelected: controller.selectedTab.value == 1,
                        onTap: () => controller.selectTab(1),
                      ),
                      const SizedBox(width: 6),
                      _buildTabChip(
                        title: 'Pending Verify',
                        count: 2,
                        isSelected: controller.selectedTab.value == 2,
                        onTap: () => controller.selectTab(2),
                      ),
                      const SizedBox(width: 6),
                      _buildTabChip(
                        title: 'Fee Plans',
                        isSelected: controller.selectedTab.value == 3,
                        onTap: () => controller.selectTab(3),
                      ),
                    ],
                  )),
            ),
            const SizedBox(height: 12),

            // Search Bar
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AlogyanColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AlogyanColors.border),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.search, size: 16, color: AlogyanColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: controller.updateSearch,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Search student name, roll no or invoice...',
                        hintStyle: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Batch filter chips
            Obx(() => Row(
                  children: [
                    _buildBatchChip('All Batches', 'ALL', controller),
                    const SizedBox(width: 6),
                    _buildBatchChip('FL-01 (8)', 'FL-01', controller),
                    const SizedBox(width: 6),
                    _buildBatchChip('ME-01 (4)', 'ME-01', controller),
                    const SizedBox(width: 6),
                    _buildBatchChip('CB-02 (2)', 'CB-02', controller),
                  ],
                )),
            const SizedBox(height: 16),

            // Student Roster List
            Obx(() {
              final students = controller.filteredStudents;
              if (students.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: const [
                        Icon(LucideIcons.checkCheck, size: 36, color: AlogyanColors.success),
                        SizedBox(height: 8),
                        Text(
                          'No pending dues found',
                          style: TextStyle(fontWeight: FontWeight.w600, color: AlogyanColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: students.map((student) => _buildStudentFeeCard(student, controller)).toList(),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Widget valueWidget,
    required Widget subText,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AlogyanColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AlogyanColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: AlogyanColors.textSecondary)),
              Icon(icon, size: 14, color: iconColor),
            ],
          ),
          const SizedBox(height: 6),
          valueWidget,
          const SizedBox(height: 3),
          subText,
        ],
      ),
    );
  }

  Widget _buildTabChip({
    required String title,
    int? count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AlogyanColors.primary : AlogyanColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AlogyanColors.primary : AlogyanColors.border),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AlogyanColors.textPrimary,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.25) : AlogyanColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AlogyanColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBatchChip(String label, String value, FeesOverviewController controller) {
    final isSelected = controller.selectedBatchFilter.value == value;
    return InkWell(
      onTap: () => controller.selectBatch(value),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AlogyanColors.surfaceMuted : AlogyanColors.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isSelected ? AlogyanColors.primary : AlogyanColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AlogyanColors.primary : AlogyanColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildStudentFeeCard(OutstandingFeeStudent student, FeesOverviewController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AlogyanCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: student.isCritical ? AlogyanColors.dangerLight : AlogyanColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                student.isCritical ? LucideIcons.alertTriangle : LucideIcons.user,
                color: student.isCritical ? AlogyanColors.danger : AlogyanColors.textSecondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        student.studentName,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AlogyanColors.textPrimary),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AlogyanColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          student.batchCode,
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AlogyanColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        student.dueDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: student.isCritical ? AlogyanColors.danger : AlogyanColors.textSecondary,
                          fontWeight: student.isCritical ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('• Roll: ${student.rollNo}', style: const TextStyle(fontSize: 11, color: AlogyanColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${student.dueAmount}',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: student.isCritical ? AlogyanColors.danger : AlogyanColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    InkWell(
                      onTap: () => controller.sendWhatsAppReminder(student),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AlogyanColors.successLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Remind', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AlogyanColors.success)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => controller.recordPaymentForStudent(student),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AlogyanColors.primaryLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Collect', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AlogyanColors.primary)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
