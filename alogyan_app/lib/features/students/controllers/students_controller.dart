import 'dart:math';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/cache/cache_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../data/repositories/student_repository.dart';

class StudentItem {
  final String id;
  final String name;
  final String batch;
  final String phone;
  int dueAmount;

  StudentItem({
    required this.id,
    required this.name,
    required this.batch,
    required this.phone,
    required this.dueAmount,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'batch': batch,
        'phone': phone,
        'dueAmount': dueAmount,
      };
}

class StudentsController extends GetxController {
  final StudentRepository? repository;
  final RxString searchQuery = ''.obs;
  final RxList<StudentItem> allStudents = <StudentItem>[].obs;

  StudentsController({this.repository});

  @override
  void onInit() {
    super.onInit();
    final repo = repository ??
        (Get.isRegistered<StudentRepository>()
            ? Get.find<StudentRepository>()
            : null);
    if (repo != null) {
      final user = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>().currentUser.value
          : null;
      allStudents.bindStream(repo.streamStudents(instituteId: user?.instituteId));
    }
  }

  int get totalPendingDues => allStudents.fold(0, (sum, s) => sum + s.dueAmount);

  List<StudentItem> get filteredStudents {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return allStudents;
    return allStudents.where((s) {
      return s.name.toLowerCase().contains(q) || s.batch.toLowerCase().contains(q);
    }).toList();
  }

  void updateSearch(String val) {
    searchQuery.value = val;
  }

  void settleStudentDue(String studentId, int paidAmount) {
    final index = allStudents.indexWhere((s) => s.id == studentId);
    if (index != -1) {
      final s = allStudents[index];
      s.dueAmount = max(0, s.dueAmount - paidAmount);
      allStudents.refresh();

      // Update in local Hive cache
      if (Get.isRegistered<CacheService>()) {
        Get.find<CacheService>().studentsBox.put(s.id, s.toMap());
      }
    }
  }

  Future<void> makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> sendWhatsApp(String phone, String studentName) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final msg = Uri.encodeComponent('Hello, regarding $studentName at Alogyan Academy: ');
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
