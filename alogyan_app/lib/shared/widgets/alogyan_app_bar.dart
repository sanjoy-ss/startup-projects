import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/constants/colors.dart';
import '../../core/sync/sync_worker.dart';
import '../../features/navigation/controllers/navigation_controller.dart';

class AlogyanAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AlogyanAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64.0);

  String _getSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Prof. Sanjoy • Physics & Maths';
      case 1:
        return 'Rapid Classroom Attendance';
      case 2:
        return 'Quick Fee Collection & Dynamic UPI';
      case 3:
        return 'Student Directory & Quick Call';
      default:
        return 'Alogyan Companion';
    }
  }

  @override
  Widget build(BuildContext context) {
    final navController = Get.isRegistered<NavigationController>()
        ? Get.find<NavigationController>()
        : Get.put(NavigationController());

    final syncWorker = Get.isRegistered<SyncWorker>() ? Get.find<SyncWorker>() : null;

    return AppBar(
      toolbarHeight: 64.0,
      elevation: 0,
      backgroundColor: AlogyanColors.surface,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16.0,
      shape: const Border(
        bottom: BorderSide(color: AlogyanColors.border, width: 1.0),
      ),
      title: Row(
        children: [
          // Alogyan Brand Badge Icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AlogyanColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AlogyanColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Dynamic Header Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Text(
                      'Alogyan Academy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AlogyanColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AlogyanColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AlogyanColors.border),
                      ),
                      child: const Text(
                        'MAIN',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AlogyanColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Obx(() => Text(
                      _getSubtitle(navController.currentIndex.value),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AlogyanColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Live Real-Time Cloud Sync Indicator
        if (syncWorker != null)
          Obx(() {
            final isOnline = syncWorker.isOnline.value;
            final pending = syncWorker.pendingSyncCount.value;
            final isSyncing = syncWorker.isSyncing.value;

            if (!isOnline) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Tooltip(
                  message: 'Offline Mode (Local Cache Active)',
                  child: InkWell(
                    onTap: syncWorker.drainQueue,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AlogyanColors.warningLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AlogyanColors.warning),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.cloudOff, size: 14, color: AlogyanColors.warning),
                          if (pending > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '$pending',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AlogyanColors.warning,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            if (pending > 0 || isSyncing) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Tooltip(
                  message: '$pending items syncing to Cloud',
                  child: InkWell(
                    onTap: syncWorker.drainQueue,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AlogyanColors.infoLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AlogyanColors.info),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$pending',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AlogyanColors.info),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Tooltip(
                message: 'All changes synced with Cloud Firestore',
                child: IconButton(
                  icon: const Icon(LucideIcons.cloudCheck, size: 20, color: AlogyanColors.success),
                  onPressed: syncWorker.drainQueue,
                ),
              ),
            );
          }),

        // Notifications action
        IconButton(
          icon: const Icon(LucideIcons.bell, size: 20, color: AlogyanColors.textPrimary),
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
