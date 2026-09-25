import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../core/sync/sync_worker.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../attendance/screens/quick_attendance_screen.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../fees/screens/quick_fee_screen.dart';
import '../../students/screens/students_screen.dart';
import '../controllers/navigation_controller.dart';

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  static const List<Widget> _pages = [
    DashboardScreen(),
    QuickAttendanceScreen(),
    QuickFeeScreen(),
    StudentsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navController = Get.put(NavigationController());
    final syncWorker = Get.isRegistered<SyncWorker>() ? Get.find<SyncWorker>() : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (syncWorker != null)
              Obx(() => OfflineBanner(
                    pendingCount: syncWorker.pendingSyncCount.value,
                    onSyncNow: syncWorker.drainQueue,
                  )),
            Expanded(
              child: Obx(() => IndexedStack(
                    index: navController.currentIndex.value,
                    children: _pages,
                  )),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AlogyanColors.border, width: 1),
          ),
        ),
        child: Obx(
          () => BottomNavigationBar(
            currentIndex: navController.currentIndex.value,
            onTap: navController.changeTab,
            type: BottomNavigationBarType.fixed,
            backgroundColor: AlogyanColors.surface,
            selectedItemColor: AlogyanColors.primary,
            unselectedItemColor: AlogyanColors.textSecondary,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.layoutDashboard, size: 22),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.userCheck, size: 22),
                label: 'Attendance',
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.indianRupee, size: 22),
                label: 'Fees',
              ),
              BottomNavigationBarItem(
                icon: Icon(LucideIcons.users, size: 22),
                label: 'Students',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
