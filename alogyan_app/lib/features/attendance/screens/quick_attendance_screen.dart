import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/primary_button.dart';
import '../controllers/attendance_controller.dart';

class QuickAttendanceScreen extends StatelessWidget {
  const QuickAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttendanceController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Batch Header & Subtitle
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Class 10 - Physics Batch',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AlogyanColors.textPrimary),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tap a student to toggle Present • Absent • Late',
                    style: TextStyle(fontSize: 12, color: AlogyanColors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AlogyanColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AlogyanColors.border),
                ),
                child: const Icon(LucideIcons.users, size: 18, color: AlogyanColors.textSecondary),
              ),
            ],
          ),
        ),

        // Live Attendance Action Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AlogyanColors.surfaceMuted,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AlogyanColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => Text(
                    '${controller.presentCount} / ${controller.totalCount} Present',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AlogyanColors.textPrimary),
                  )),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AlogyanColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(LucideIcons.checkCheck, size: 16),
                onPressed: controller.markAllPresent,
                label: const Text('Mark All Present', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
        ),

        // Student Roster
        Expanded(
          child: Obx(() {
            final students = controller.students;
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: students.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AlogyanColors.border),
              itemBuilder: (context, index) {
                final student = students[index];
                final status = student.status;

                Color badgeBg = AlogyanColors.successLight;
                Color badgeFg = AlogyanColors.success;
                if (status == 'absent') {
                  badgeBg = AlogyanColors.dangerLight;
                  badgeFg = AlogyanColors.danger;
                } else if (status == 'late') {
                  badgeBg = AlogyanColors.warningLight;
                  badgeFg = AlogyanColors.warning;
                }

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                  leading: CircleAvatar(
                    backgroundColor: AlogyanColors.surfaceMuted,
                    child: Text(
                      student.name.substring(0, 1),
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AlogyanColors.textPrimary),
                    ),
                  ),
                  title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('Roll #${student.roll}', style: const TextStyle(fontSize: 12, color: AlogyanColors.textSecondary)),
                  trailing: InkWell(
                    onTap: () => controller.toggleStatus(index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 90,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(color: badgeFg, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),

        // Bottom Submission Bar
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: Obx(() => PrimaryButton(
                    text: 'Submit Attendance (${controller.presentCount}/${controller.totalCount})',
                    isLoading: controller.isSubmitting.value,
                    onPressed: controller.submitAttendance,
                  )),
            ),
          ),
        ),
      ],
    );
  }
}
