import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/alogyan_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../navigation/controllers/navigation_controller.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    final navController = Get.isRegistered<NavigationController>()
        ? Get.find<NavigationController>()
        : Get.put(NavigationController());

    final currencyFormatter = NumberFormat('#,##,###');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Classroom Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AlogyanColors.textPrimary),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Real-time metrics for today',
                    style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AlogyanColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Icon(LucideIcons.calendar, size: 12, color: AlogyanColors.primary),
                    SizedBox(width: 4),
                    Text(
                      'TODAY',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AlogyanColors.primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Reactive Stat Tiles
          Row(
            children: [
              Expanded(
                child: AlogyanCard(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(LucideIcons.bookOpen, size: 16, color: AlogyanColors.primary),
                          SizedBox(width: 6),
                          Text('Today Batches', style: TextStyle(fontSize: 12, color: AlogyanColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                            '${controller.todayClassesCount} Batches',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AlogyanColors.primary),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AlogyanCard(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(LucideIcons.indianRupee, size: 16, color: AlogyanColors.danger),
                          SizedBox(width: 6),
                          Text('Pending Dues', style: TextStyle(fontSize: 12, color: AlogyanColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Text(
                            '₹${currencyFormatter.format(controller.totalPendingDues)}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AlogyanColors.danger),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Classroom Floor Shortcuts
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AlogyanColors.textPrimary),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AlogyanColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(LucideIcons.userCheck, size: 18),
                  label: const Text('Take Attendance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  onPressed: () => navController.changeTab(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AlogyanColors.textPrimary,
                    side: const BorderSide(color: AlogyanColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(LucideIcons.indianRupee, size: 18),
                  label: const Text('Collect Fee', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  onPressed: () => navController.changeTab(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Today's Class Timeline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Schedule",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AlogyanColors.textPrimary),
              ),
              Obx(() => Text(
                    '${controller.todayClassesCount} ${controller.todayClassesCount == 1 ? 'class' : 'classes'} scheduled',
                    style: const TextStyle(fontSize: 12, color: AlogyanColors.textSecondary),
                  )),
            ],
          ),
          const SizedBox(height: 12),

          // Dynamic Batch Cards
          Obx(() {
            final schedule = controller.todaySchedule;
            if (schedule.isEmpty) {
              return AlogyanCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AlogyanColors.surfaceMuted,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.calendarCheck, size: 28, color: AlogyanColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No Classes Scheduled Today',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AlogyanColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Enjoy your free time or schedule a new batch session in your institute portal.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AlogyanColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: schedule.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = schedule[index];
                return AlogyanCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.time,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AlogyanColors.textSecondary),
                          ),
                          StatusBadge(label: item.status, type: item.statusType),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.batchName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AlogyanColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.mapPin, size: 14, color: AlogyanColors.textMuted),
                              const SizedBox(width: 4),
                              Text(item.roomOrMeet, style: const TextStyle(fontSize: 13, color: AlogyanColors.textSecondary)),
                            ],
                          ),
                          if (item.meetLink != null)
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              icon: const Icon(LucideIcons.video, size: 14, color: AlogyanColors.info),
                              label: const Text('Start Meet', style: TextStyle(fontSize: 12, color: AlogyanColors.info)),
                              onPressed: () => controller.launchClassLink(item.meetLink),
                            ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
