import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/repositories/student_repository.dart';

class StudentItem {
  final String id;
  final String name;
  final String batch;
  final String phone;
  final int dueAmount;

  StudentItem({
    required this.id,
    required this.name,
    required this.batch,
    required this.phone,
    required this.dueAmount,
  });
}

class StudentsController extends GetxController {
  final StudentRepository? repository;
  final RxString searchQuery = ''.obs;
  final RxList<StudentItem> allStudents = <StudentItem>[].obs;

  StudentsController({this.repository}) {
    allStudents.assignAll([
      StudentItem(id: '1', name: 'Aarav Sharma', batch: 'Class 10 Physics', phone: '+919876543210', dueAmount: 0),
      StudentItem(id: '2', name: 'Diya Sen', batch: 'Class 10 Physics', phone: '+919876543211', dueAmount: 2000),
      StudentItem(id: '3', name: 'Ishaan Roy', batch: 'Class 12 Maths', phone: '+919876543212', dueAmount: 3500),
      StudentItem(id: '4', name: 'Meera Patel', batch: 'Class 10 Physics', phone: '+919876543213', dueAmount: 0),
      StudentItem(id: '5', name: 'Rohan Das', batch: 'Class 12 Maths', phone: '+919876543214', dueAmount: 2000),
    ]);
  }

  @override
  void onInit() {
    super.onInit();
    if (repository != null) {
      allStudents.bindStream(repository!.streamStudents());
    } else if (Get.isRegistered<StudentRepository>()) {
      allStudents.bindStream(Get.find<StudentRepository>().streamStudents());
    }
  }

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
