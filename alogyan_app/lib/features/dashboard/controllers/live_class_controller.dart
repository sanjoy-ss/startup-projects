import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/colors.dart';

class LiveClassController extends GetxController {
  // Live Class State
  final RxString batchTitle = 'Flutter Foundations (FL-01) • Mobile Engineering'.obs;
  final RxString topicTitle = 'Flutter Layouts and Responsive UI'.obs;
  final RxString classTime = 'Tuesday, 6 October 2026 • 6:00 PM – 7:00 PM'.obs;
  final RxString timezone = 'Asia/Kolkata (IST Standard Time)'.obs;
  final RxInt enrolledCount = 24.obs;
  final RxInt inLobbyCount = 14.obs;
  final RxString meetingProvider = 'Google Meet HD Video'.obs;
  final RxString hostEmail = 'sanjoy.sarkar@alogyan.ac.in'.obs;
  final RxString meetUrl = 'https://meet.google.com/alo-gyan-xyz'.obs;

  final RxBool isStarting = false.obs;
  final RxBool hasCopiedLink = false.obs;

  // Whiteboard State
  final RxBool canDraw = false.obs;
  final RxString selectedTool = 'pen'.obs; // 'pen', 'eraser', 'text', 'rectangle'
  final Rx<Color> selectedColor = AlogyanColors.primary.obs;
  final RxDouble strokeWidth = 2.0.obs;
  final RxInt activeViewers = 18.obs;
  final RxBool isLandscapeNoticeVisible = true.obs;

  Future<void> launchMeet() async {
    isStarting.value = true;
    final uri = Uri.parse(meetUrl.value);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Launch Failed', 'Could not open Google Meet URL');
    }
    isStarting.value = false;
  }

  void copyMeetingLink() {
    Clipboard.setData(ClipboardData(text: meetUrl.value));
    hasCopiedLink.value = true;
    Get.snackbar(
      'Link Copied',
      'Google Meet link copied to clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void toggleDrawingPermission() {
    canDraw.value = !canDraw.value;
    Get.snackbar(
      canDraw.value ? 'Drawing Mode Enabled' : 'View-Only Mode',
      canDraw.value ? 'You can now annotate on the canvas.' : 'Whiteboard is now locked to view-only.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  void selectTool(String tool) {
    selectedTool.value = tool;
  }

  void selectColor(Color color) {
    selectedColor.value = color;
  }

  void dismissLandscapeHint() {
    isLandscapeNoticeVisible.value = false;
  }
}
