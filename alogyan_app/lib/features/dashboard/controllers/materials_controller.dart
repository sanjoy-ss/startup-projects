import 'package:get/get.dart';
import '../models/dashboard_models.dart';

class MaterialsController extends GetxController {
  final RxString selectedBatchFilter = 'ALL'.obs; // 'ALL', 'FL-01', 'ME-01', 'CB-02'
  final RxString selectedCategory = 'ALL'.obs; // 'ALL', 'PDF', 'CODE', 'LINKS', 'RECORDINGS'
  final RxString searchQuery = ''.obs;

  final RxString storageUsed = '342 MB'.obs;
  final RxString storageTotal = '5 GB'.obs;
  final RxInt totalFilesCount = 38.obs;
  final RxInt cachedItemsCount = 4.obs;
  final RxString cachedItemsSize = '18 MB'.obs;

  final RxList<CurriculumMaterialItem> allMaterials = <CurriculumMaterialItem>[
    const CurriculumMaterialItem(
      id: 'mat-1',
      title: 'Flutter Layout Practice & Responsive Templates.pdf',
      batchCode: 'FL-01',
      fileType: 'pdf',
      fileSize: '2.4 MB',
      uploadDate: 'Today, 2:00 PM',
      isPinned: true,
      isCached: true,
    ),
    const CurriculumMaterialItem(
      id: 'mat-2',
      title: 'State Management with GetX Cheatsheet.dart',
      batchCode: 'FL-01',
      fileType: 'code',
      fileSize: '156 KB',
      uploadDate: 'Yesterday',
      isPinned: true,
      isCached: true,
    ),
    const CurriculumMaterialItem(
      id: 'mat-3',
      title: 'MERN Stack API Authentication Architecture.pdf',
      batchCode: 'ME-01',
      fileType: 'pdf',
      fileSize: '4.8 MB',
      uploadDate: '04 Oct 2026',
      isPinned: false,
      isCached: false,
    ),
    const CurriculumMaterialItem(
      id: 'mat-4',
      title: 'Express REST Router Boilerplate Repository',
      batchCode: 'ME-01',
      fileType: 'link',
      fileSize: 'GitHub URL',
      uploadDate: '03 Oct 2026',
      isPinned: false,
      isCached: false,
    ),
    const CurriculumMaterialItem(
      id: 'mat-5',
      title: 'Computer Basics Hardware & OS Slide Deck.pptx',
      batchCode: 'CB-02',
      fileType: 'pdf',
      fileSize: '8.1 MB',
      uploadDate: '01 Oct 2026',
      isPinned: false,
      isCached: true,
    ),
  ].obs;

  List<CurriculumMaterialItem> get filteredMaterials {
    return allMaterials.where((item) {
      final matchesBatch = selectedBatchFilter.value == 'ALL' || item.batchCode == selectedBatchFilter.value;
      final matchesCat = selectedCategory.value == 'ALL' || item.fileType.toUpperCase() == selectedCategory.value;
      final q = searchQuery.value.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          item.title.toLowerCase().contains(q) ||
          item.batchCode.toLowerCase().contains(q);
      return matchesBatch && matchesCat && matchesQuery;
    }).toList();
  }

  void selectBatch(String batch) {
    selectedBatchFilter.value = batch;
  }

  void selectCategory(String cat) {
    selectedCategory.value = cat;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void downloadOrOpen(CurriculumMaterialItem item) {
    Get.snackbar(
      'Document Accessed',
      'Opening ${item.title} (${item.fileSize})',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
