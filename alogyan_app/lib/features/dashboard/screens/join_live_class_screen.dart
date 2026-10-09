import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/alogyan_card.dart';
import '../controllers/live_class_controller.dart';
import 'whiteboard_screen.dart';

class JoinLiveClassScreen extends StatelessWidget {
  const JoinLiveClassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<LiveClassController>()
        ? Get.find<LiveClassController>()
        : Get.put(LiveClassController());

    return Scaffold(
      backgroundColor: AlogyanColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Join Live Class',
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
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: AlogyanColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.user, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status ribbon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AlogyanColors.successLight,
                    borderRadius: BorderRadius.circular(6),
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
                      const Text(
                        'Starting in 10 mins',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AlogyanColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: const [
                    Icon(LucideIcons.radio, size: 15, color: AlogyanColors.success),
                    SizedBox(width: 4),
                    Text(
                      'Sync Ready',
                      style: TextStyle(fontSize: 12, color: AlogyanColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Live Class Header Card
            AlogyanCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(
                                  controller.batchTitle.value,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AlogyanColors.textSecondary,
                                    letterSpacing: 0.3,
                                  ),
                                )),
                            const SizedBox(height: 4),
                            Obx(() => Text(
                                  controller.topicTitle.value,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AlogyanColors.textPrimary,
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AlogyanColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(LucideIcons.laptop, color: AlogyanColors.primary, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(LucideIcons.calendar, size: 15, color: AlogyanColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Obx(() => Text(
                              controller.classTime.value,
                              style: const TextStyle(fontSize: 12.5, color: AlogyanColors.textPrimary),
                            )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(LucideIcons.globe, size: 15, color: AlogyanColors.textSecondary),
                      const SizedBox(width: 8),
                      Obx(() => Text(
                            controller.timezone.value,
                            style: const TextStyle(fontSize: 12, color: AlogyanColors.textSecondary),
                          )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AlogyanColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(LucideIcons.users, size: 16, color: AlogyanColors.primary),
                            const SizedBox(width: 6),
                            Obx(() => Text(
                                  '${controller.enrolledCount.value} Enrolled Students',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AlogyanColors.textPrimary,
                                  ),
                                )),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AlogyanColors.successLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Obx(() => Text(
                                '${controller.inLobbyCount.value} in Lobby',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AlogyanColors.success,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Provider Handoff Card
            AlogyanCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AlogyanColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(LucideIcons.video, color: AlogyanColors.primary, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Obx(() => Text(
                                        controller.meetingProvider.value,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: AlogyanColors.textPrimary,
                                        ),
                                      )),
                                  const SizedBox(width: 4),
                                  const Icon(LucideIcons.badgeCheck, size: 15, color: AlogyanColors.success),
                                ],
                              ),
                              const Text(
                                'Alogyan Enterprise Workspace',
                                style: TextStyle(fontSize: 11.5, color: AlogyanColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Get.snackbar('A/V Diagnostic', 'Microphone and camera ready for transmission.');
                        },
                        icon: const Icon(LucideIcons.externalLink, size: 13),
                        label: const Text('Test A/V'),
                        style: TextButton.styleFrom(
                          foregroundColor: AlogyanColors.primary,
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AlogyanColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.shieldCheck, size: 18, color: AlogyanColors.textSecondary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Host Credentials',
                                style: TextStyle(fontSize: 11, color: AlogyanColors.textSecondary),
                              ),
                              Obx(() => Text(
                                    controller.hostEmail.value,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AlogyanColors.textPrimary,
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AlogyanColors.successLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Host Verified',
                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AlogyanColors.success),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(LucideIcons.info, size: 14, color: AlogyanColors.textSecondary),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Google Meet opens in your app or browser. After the session, return to Alogyan CMS to sync participation and finalize attendance.',
                          style: TextStyle(fontSize: 11.5, color: AlogyanColors.textSecondary, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons Stack
            Obx(() => ElevatedButton.icon(
                  onPressed: controller.isStarting.value ? null : controller.launchMeet,
                  icon: controller.isStarting.value
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Icon(LucideIcons.play, size: 18),
                  label: Text(controller.isStarting.value ? 'Connecting...' : 'Start / Join Meeting'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AlogyanColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                )),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.copyMeetingLink,
                    icon: const Icon(LucideIcons.copy, size: 16),
                    label: const Text('Copy Link'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AlogyanColors.textPrimary,
                      side: const BorderSide(color: AlogyanColors.border),
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.to(() => const WhiteboardScreen()),
                    icon: const Icon(LucideIcons.penTool, size: 16),
                    label: const Text('Whiteboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AlogyanColors.surfaceMuted,
                      foregroundColor: AlogyanColors.textPrimary,
                      side: const BorderSide(color: AlogyanColors.border),
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
