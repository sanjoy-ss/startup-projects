import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/constants/colors.dart';
import '../../features/auth/controllers/auth_controller.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/navigation/controllers/navigation_controller.dart';

class AlogyanAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AlogyanAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  String _getSubtitle(int index, UserModel? user) {
    final educatorInfo = user != null
        ? '${user.name} • ${user.subject.isNotEmpty ? user.subject : user.designation}'
        : 'Educator Workspace';
    switch (index) {
      case 0:
        return educatorInfo;
      case 1:
        return 'Rapid Classroom Attendance';
      case 2:
        return 'Quick Fee Collection & Dynamic UPI';
      case 3:
        return 'Educator Profile & Settings';
      default:
        return 'Alogyan Companion';
    }
  }

  @override
  Widget build(BuildContext context) {
    final navController = Get.isRegistered<NavigationController>()
        ? Get.find<NavigationController>()
        : Get.put(NavigationController());

    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;

    return AppBar(
      toolbarHeight: 64.0,
      elevation: 0,
      backgroundColor: AlogyanColors.surface,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 0,
      shape: const Border(
        bottom: BorderSide(color: AlogyanColors.border, width: 1.0),
      ),
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(
            LucideIcons.menu,
            size: 22,
            color: AlogyanColors.textPrimary,
          ),
          tooltip: 'Open Navigation Drawer',
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        children: [
          const SizedBox(width: 4),
          // Dynamic Header Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  final user = authController?.currentUser.value;
                  return Row(
                    children: [
                      Flexible(
                        child: Text(
                          user?.instituteName ?? 'Alogyan Academy',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AlogyanColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AlogyanColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AlogyanColors.border),
                        ),
                        child: Text(
                          user?.activeBranchName.toUpperCase() ?? 'MAIN',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AlogyanColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 2),
                Obx(() {
                  final user = authController?.currentUser.value;
                  return Text(
                    _getSubtitle(navController.currentIndex.value, user),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AlogyanColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Notifications action
        IconButton(
          icon: const Icon(
            LucideIcons.bell,
            size: 20,
            color: AlogyanColors.textPrimary,
          ),
          tooltip: 'Announcements & Alerts',
          onPressed: () {
            Get.snackbar(
              'No Unread Alerts',
              'All classroom schedules are up to date.',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
