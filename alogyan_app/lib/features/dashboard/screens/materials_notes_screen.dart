import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/alogyan_card.dart';
import '../controllers/materials_controller.dart';
import '../models/dashboard_models.dart';

class MaterialsNotesScreen extends StatelessWidget {
  const MaterialsNotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<MaterialsController>()
        ? Get.find<MaterialsController>()
        : Get.put(MaterialsController());

    return Scaffold(
      backgroundColor: AlogyanColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Materials & Notes',
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
          IconButton(
            icon: const Icon(LucideIcons.uploadCloud, size: 20, color: AlogyanColors.primary),
            tooltip: 'Upload Material',
            onPressed: () {
              Get.snackbar('Upload Document', 'Select PDF, slides or source file to share with batches.');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campus context & Upload Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'AGARTALA CAMPUS • 3 ACTIVE BATCHES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AlogyanColors.textSecondary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Academic Session 2026-27',
                      style: TextStyle(fontSize: 12, color: AlogyanColors.textSecondary),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Get.snackbar('Upload Document', 'Opening file picker...');
                  },
                  icon: const Icon(LucideIcons.upload, size: 14),
                  label: const Text('Upload'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AlogyanColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Live Storage & Offline Sync Status Card
            AlogyanCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AlogyanColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(LucideIcons.cloud, color: AlogyanColors.textSecondary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                                '${controller.storageUsed.value} of ${controller.storageTotal.value} used',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AlogyanColors.textPrimary),
                              )),
                          Obx(() => Text(
                                '${controller.totalFilesCount.value} active curriculum files',
                                style: const TextStyle(fontSize: 11, color: AlogyanColors.textSecondary),
                              )),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AlogyanColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: AlogyanColors.success, shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Obx(() => Text(
                              'Cached: ${controller.cachedItemsCount.value} items',
                              style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: AlogyanColors.textSecondary),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Search input
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AlogyanColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AlogyanColors.border),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.search, size: 16, color: AlogyanColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      onChanged: controller.updateSearch,
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Search notes, slides, PDFs, code repos...',
                        hintStyle: TextStyle(fontSize: 12.5, color: AlogyanColors.textSecondary),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Batch filters
            const Text(
              'FILTER BY BATCH',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AlogyanColors.textSecondary, letterSpacing: 0.3),
            ),
            const SizedBox(height: 6),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                    children: [
                      _buildBatchPill('All Batches', 'ALL', '38', controller),
                      const SizedBox(width: 6),
                      _buildBatchPill('FL-01', 'FL-01', '18', controller),
                      const SizedBox(width: 6),
                      _buildBatchPill('ME-01', 'ME-01', '12', controller),
                      const SizedBox(width: 6),
                      _buildBatchPill('CB-02', 'CB-02', '8', controller),
                    ],
                  )),
            ),
            const SizedBox(height: 10),

            // Category filters
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(() => Row(
                    children: [
                      _buildCategoryChip('All (38)', 'ALL', controller),
                      const SizedBox(width: 6),
                      _buildCategoryChip('PDFs / Docs', 'PDF', controller),
                      const SizedBox(width: 6),
                      _buildCategoryChip('Code & Cheatsheets', 'CODE', controller),
                      const SizedBox(width: 6),
                      _buildCategoryChip('Links', 'LINK', controller),
                    ],
                  )),
            ),
            const SizedBox(height: 16),

            // Pinned Curriculum Materials
            Row(
              children: const [
                Icon(LucideIcons.pin, size: 15, color: AlogyanColors.primary),
                SizedBox(width: 6),
                Text(
                  'Pinned for Upcoming Class',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AlogyanColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Obx(() {
              final materials = controller.filteredMaterials;
              if (materials.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      'No curriculum documents found for this filter.',
                      style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary),
                    ),
                  ),
                );
              }
              return Column(
                children: materials.map((item) => _buildMaterialTile(item, controller)).toList(),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchPill(String title, String batchCode, String count, MaterialsController controller) {
    final isSelected = controller.selectedBatchFilter.value == batchCode;
    return InkWell(
      onTap: () => controller.selectBatch(batchCode),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AlogyanColors.primaryLight : AlogyanColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AlogyanColors.primary : AlogyanColors.border),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AlogyanColors.primary : AlogyanColors.textSecondary,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? AlogyanColors.primary : AlogyanColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AlogyanColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String title, String category, MaterialsController controller) {
    final isSelected = controller.selectedCategory.value == category;
    return InkWell(
      onTap: () => controller.selectCategory(category),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AlogyanColors.textPrimary : AlogyanColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AlogyanColors.textPrimary : AlogyanColors.border),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AlogyanColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialTile(CurriculumMaterialItem item, MaterialsController controller) {
    IconData icon;
    Color iconColor;
    switch (item.fileType) {
      case 'pdf':
        icon = LucideIcons.fileText;
        iconColor = AlogyanColors.primary;
        break;
      case 'code':
        icon = LucideIcons.code;
        iconColor = AlogyanColors.info;
        break;
      case 'link':
        icon = LucideIcons.link;
        iconColor = AlogyanColors.textSecondary;
        break;
      default:
        icon = LucideIcons.file;
        iconColor = AlogyanColors.textSecondary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AlogyanCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AlogyanColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AlogyanColors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.isPinned) ...[
                        const SizedBox(width: 4),
                        const Icon(LucideIcons.pin, size: 12, color: AlogyanColors.primary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AlogyanColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          item.batchCode,
                          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: AlogyanColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(item.fileSize, style: const TextStyle(fontSize: 11, color: AlogyanColors.textSecondary)),
                      const SizedBox(width: 6),
                      Text('• ${item.uploadDate}', style: const TextStyle(fontSize: 11, color: AlogyanColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.download, size: 18, color: AlogyanColors.textSecondary),
              tooltip: 'Download',
              onPressed: () => controller.downloadOrOpen(item),
            ),
          ],
        ),
      ),
    );
  }
}
