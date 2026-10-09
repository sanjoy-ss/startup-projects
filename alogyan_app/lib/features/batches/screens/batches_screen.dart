import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../../../shared/widgets/alogyan_card.dart';
import '../controllers/batches_controller.dart';
import '../widgets/batch_card.dart';

class BatchesScreen extends StatelessWidget {
  const BatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<BatchesController>()
        ? Get.find<BatchesController>()
        : Get.put(BatchesController());

    final searchController = TextEditingController(text: controller.searchQuery.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Screen Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Batches Directory',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AlogyanColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Classroom rosters, schedules & 1-tap attendance',
                    style: TextStyle(
                      fontSize: 12,
                      color: AlogyanColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AlogyanColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${controller.totalBatches} Active',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AlogyanColors.primary,
                      ),
                    ),
                  )),
            ],
          ),
        ),

        // 2. Micro Stats Summary Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Obx(
            () => Row(
              children: [
                Expanded(
                  child: AlogyanCard(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(LucideIcons.bookOpen, size: 13, color: AlogyanColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Batches',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AlogyanColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${controller.totalBatches}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AlogyanColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AlogyanCard(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(LucideIcons.users, size: 13, color: AlogyanColors.info),
                            SizedBox(width: 4),
                            Text(
                              'Students',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AlogyanColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${controller.totalEnrolledStudents}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AlogyanColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AlogyanCard(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(LucideIcons.calendarCheck, size: 13, color: AlogyanColors.success),
                            SizedBox(width: 4),
                            Text(
                              'Today',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AlogyanColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${controller.todaySessionsCount} Sessions',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AlogyanColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Obx(() {
            final hasQuery = controller.searchQuery.value.isNotEmpty;
            return TextField(
              controller: searchController,
              onChanged: controller.updateSearch,
              decoration: InputDecoration(
                hintText: 'Search batch name, subject or room...',
                hintStyle: const TextStyle(fontSize: 13, color: AlogyanColors.textMuted),
                prefixIcon: const Icon(LucideIcons.search, size: 18, color: AlogyanColors.textSecondary),
                suffixIcon: hasQuery
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 16, color: AlogyanColors.textMuted),
                        onPressed: () {
                          searchController.clear();
                          controller.updateSearch('');
                        },
                      )
                    : null,
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AlogyanColors.primary, width: 1.5),
                ),
              ),
            );
          }),
        ),

        // 4. Quick Category Filter Chips
        Container(
          height: 38,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Obx(() {
            final activeFilter = controller.selectedFilter.value;
            final filters = [
              {'id': 'all', 'label': 'All Batches'},
              {'id': 'today', 'label': "Today's Schedule"},
              {'id': 'online', 'label': 'Online Classes'},
              {'id': 'offline', 'label': 'Campus Hall'},
            ];

            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final f = filters[index];
                final isSelected = activeFilter == f['id'];

                return ChoiceChip(
                  label: Text(f['label']!),
                  selected: isSelected,
                  selectedColor: AlogyanColors.primary,
                  backgroundColor: AlogyanColors.surface,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AlogyanColors.textPrimary,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: isSelected ? AlogyanColors.primary : AlogyanColors.border,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      controller.setFilter(f['id']!);
                    }
                  },
                );
              },
            );
          }),
        ),

        // 5. Reactive Batches List
        Expanded(
          child: Obx(() {
            final batches = controller.filteredBatches;

            if (batches.isEmpty) {
              final isFiltered = controller.searchQuery.value.isNotEmpty ||
                  controller.selectedFilter.value != 'all';

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
                          LucideIcons.bookOpen,
                          size: 32,
                          color: AlogyanColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        isFiltered ? 'No Batches Found' : 'No Active Batches',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AlogyanColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isFiltered
                            ? 'No batch matches your search query or filter. Try clearing filters.'
                            : 'Batches created on the Web CMS will automatically sync here in real-time.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AlogyanColors.textSecondary,
                        ),
                      ),
                      if (isFiltered) ...[
                        const SizedBox(height: 16),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AlogyanColors.primary,
                            side: const BorderSide(color: AlogyanColors.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            searchController.clear();
                            controller.updateSearch('');
                            controller.setFilter('all');
                          },
                          child: const Text('Reset Filters'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              color: AlogyanColors.primary,
              onRefresh: controller.refreshBatches,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: batches.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return BatchCard(batch: batches[index]);
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
