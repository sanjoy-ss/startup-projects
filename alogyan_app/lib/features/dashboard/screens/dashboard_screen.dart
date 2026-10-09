import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../controllers/dashboard_controller.dart';
import 'executive_dashboard_view.dart';
import 'teacher_home_view.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DashboardController>()
        ? Get.find<DashboardController>()
        : Get.put(DashboardController());

    return Scaffold(
      backgroundColor: AlogyanColors.background,
      body: Column(
        children: [
          // Top View Mode Toggle: Teacher Home vs Executive Campus Dashboard
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AlogyanColors.surface,
              border: Border(
                bottom: BorderSide(color: AlogyanColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AlogyanColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Obx(() {
                      final isTeacher = controller.currentDashboardTab.value == 'teacher';
                      return Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.switchDashboardTab('teacher'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: isTeacher ? AlogyanColors.surface : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: isTeacher
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.graduationCap,
                                      size: 15,
                                      color: isTeacher ? AlogyanColors.primary : AlogyanColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Teacher Home',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isTeacher ? FontWeight.w700 : FontWeight.w500,
                                        color: isTeacher ? AlogyanColors.primary : AlogyanColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.switchDashboardTab('executive'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: !isTeacher ? AlogyanColors.surface : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: !isTeacher
                                      ? [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 4,
                                            offset: const Offset(0, 1),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      LucideIcons.barChart3,
                                      size: 15,
                                      color: !isTeacher ? AlogyanColors.primary : AlogyanColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Executive Vitals',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: !isTeacher ? FontWeight.w700 : FontWeight.w500,
                                        color: !isTeacher ? AlogyanColors.primary : AlogyanColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                // Quick navigation popover menu for sub-screens
                PopupMenuButton<String>(
                  icon: const Icon(LucideIcons.layoutGrid, color: AlogyanColors.textSecondary, size: 20),
                  tooltip: 'Stitch Screens',
                  onSelected: (value) {
                    switch (value) {
                      case 'live':
                        controller.openJoinLiveClass();
                        break;
                      case 'whiteboard':
                        controller.openWhiteboard();
                        break;
                      case 'fees':
                        controller.openFeesOverview();
                        break;
                      case 'materials':
                        controller.openMaterialsNotes();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'live',
                      child: Row(
                        children: [
                          Icon(LucideIcons.video, size: 16, color: AlogyanColors.primary),
                          SizedBox(width: 8),
                          Text('Join Live Class (60m)'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'whiteboard',
                      child: Row(
                        children: [
                          Icon(LucideIcons.penTool, size: 16, color: AlogyanColors.textSecondary),
                          SizedBox(width: 8),
                          Text('Interactive Whiteboard'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'fees',
                      child: Row(
                        children: [
                          Icon(LucideIcons.indianRupee, size: 16, color: AlogyanColors.success),
                          SizedBox(width: 8),
                          Text('Fees & Collections'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'materials',
                      child: Row(
                        children: [
                          Icon(LucideIcons.fileText, size: 16, color: AlogyanColors.info),
                          SizedBox(width: 8),
                          Text('Materials & Notes'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Dashboard Page View (Stateless & Reactive via Obx)
          Expanded(
            child: Obx(() {
              if (controller.currentDashboardTab.value == 'executive') {
                return const ExecutiveDashboardView();
              }
              return const TeacherHomeView();
            }),
          ),
        ],
      ),
    );
  }
}
