import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/alogyan_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../controllers/students_controller.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<StudentsController>()
        ? Get.find<StudentsController>()
        : Get.put(StudentsController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Student Directory',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AlogyanColors.textPrimary),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '1-tap Phone Call & WhatsApp alert links',
                    style: TextStyle(fontSize: 12, color: AlogyanColors.textSecondary),
                  ),
                ],
              ),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AlogyanColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AlogyanColors.border),
                    ),
                    child: Text(
                      '${controller.allStudents.length} Total',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AlogyanColors.textSecondary),
                    ),
                  )),
            ],
          ),
        ),

        // Search Input
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: controller.updateSearch,
            decoration: InputDecoration(
              hintText: 'Search by student name or batch...',
              hintStyle: const TextStyle(fontSize: 13, color: AlogyanColors.textMuted),
              prefixIcon: const Icon(LucideIcons.search, size: 18, color: AlogyanColors.textSecondary),
              filled: true,
              fillColor: AlogyanColors.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AlogyanColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AlogyanColors.border),
              ),
            ),
          ),
        ),

        // Students List
        Expanded(
          child: Obx(() {
            final list = controller.filteredStudents;
            if (list.isEmpty) {
              final isSearching = controller.searchQuery.value.isNotEmpty;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: AlogyanColors.surfaceMuted,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.users,
                          size: 36,
                          color: AlogyanColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isSearching
                            ? 'No students match "${controller.searchQuery.value}"'
                            : 'No students enrolled yet',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AlogyanColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isSearching
                            ? 'Try searching by a different name or batch.'
                            : 'Students enrolled in your institute will appear here automatically for rapid calling and attendance.',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AlogyanColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: list.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final student = list[index];
                final hasDue = student.dueAmount > 0;

                return AlogyanCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AlogyanColors.primaryLight,
                        child: Text(
                          student.name.isNotEmpty
                              ? student.name.substring(0, 1).toUpperCase()
                              : 'S',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AlogyanColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 2),
                            Text(student.batch, style: const TextStyle(color: AlogyanColors.textSecondary, fontSize: 12)),
                            const SizedBox(height: 4),
                            StatusBadge(
                              label: hasDue ? 'Due: ₹${student.dueAmount}' : 'Paid',
                              type: hasDue ? StatusBadgeType.danger : StatusBadgeType.success,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.phone, size: 20, color: AlogyanColors.info),
                        tooltip: 'Call Student/Parent',
                        onPressed: () => controller.makeCall(student.phone),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.messageCircle, size: 20, color: AlogyanColors.success),
                        tooltip: 'Send WhatsApp Alert',
                        onPressed: () => controller.sendWhatsApp(student.phone, student.name),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
