import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/primary_button.dart';
import '../controllers/attendance_controller.dart';

class QuickAttendanceScreen extends StatelessWidget {
  const QuickAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AttendanceController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapid Attendance (Class 10 Physics)'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AlogyanColors.surfaceMuted,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                      '${controller.presentCount} / ${controller.totalCount} Present',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )),
                TextButton(
                  onPressed: controller.markAllPresent,
                  child: const Text('Mark All Present'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              final students = controller.students;
              return ListView.separated(
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
                    title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('Roll #${student.roll}'),
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
          SafeArea(
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
      ),
    );
  }
}
