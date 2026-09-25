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
    final controller = Get.put(StudentsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Students Directory'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: controller.updateSearch,
              decoration: InputDecoration(
                hintText: 'Search by student name or batch...',
                prefixIcon: const Icon(LucideIcons.search, size: 18),
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
          Expanded(
            child: Obx(() {
              final list = controller.filteredStudents;
              if (list.isEmpty) {
                return const Center(
                  child: Text('No students found', style: TextStyle(color: AlogyanColors.textSecondary)),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                            student.name.substring(0, 1),
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
      ),
    );
  }
}
