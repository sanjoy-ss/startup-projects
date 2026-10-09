import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/dashboard_models.dart';

class FeesOverviewController extends GetxController {
  final RxString selectedPeriod = 'October 2026'.obs;
  final RxInt selectedTab = 0.obs; // 0: Outstanding, 1: Recent, 2: Pending Verify, 3: Fee Plans
  final RxString selectedBatchFilter = 'ALL'.obs; // 'ALL', 'FL-01', 'ME-01', 'CB-02'
  final RxString searchQuery = ''.obs;

  // KPI Metrics
  final RxInt totalCollected = 45000.obs;
  final RxInt totalPending = 12500.obs;
  final RxInt totalOverdue = 4200.obs;
  final RxInt receiptsCount = 32.obs;
  final RxInt pendingStudentsCount = 14.obs;
  final RxInt criticalOverdueCount = 5.obs;

  // Outstanding Students list
  final RxList<OutstandingFeeStudent> allOutstandingStudents = <OutstandingFeeStudent>[
    const OutstandingFeeStudent(
      id: 'fee-1',
      studentName: 'Subhasish Ghosh',
      rollNo: 'FL-012',
      batchCode: 'FL-01',
      dueAmount: 1500,
      dueDate: 'Due 10 Oct',
      isCritical: false,
      guardianContact: '+919876543210',
    ),
    const OutstandingFeeStudent(
      id: 'fee-2',
      studentName: 'Tanmoy Sen',
      rollNo: 'FL-019',
      batchCode: 'FL-01',
      dueAmount: 2000,
      dueDate: 'Overdue by 4 days',
      isCritical: true,
      guardianContact: '+919876543211',
    ),
    const OutstandingFeeStudent(
      id: 'fee-3',
      studentName: 'Priya Majumder',
      rollNo: 'ME-004',
      batchCode: 'ME-01',
      dueAmount: 1200,
      dueDate: 'Due 12 Oct',
      isCritical: false,
      guardianContact: '+919876543212',
    ),
    const OutstandingFeeStudent(
      id: 'fee-4',
      studentName: 'Rahul Debnath',
      rollNo: 'ME-008',
      batchCode: 'ME-01',
      dueAmount: 1200,
      dueDate: 'Overdue by 7 days',
      isCritical: true,
      guardianContact: '+919876543213',
    ),
    const OutstandingFeeStudent(
      id: 'fee-5',
      studentName: 'Debabrata Das',
      rollNo: 'CB-015',
      batchCode: 'CB-02',
      dueAmount: 1000,
      dueDate: 'Due 15 Oct',
      isCritical: false,
      guardianContact: '+919876543214',
    ),
  ].obs;

  List<OutstandingFeeStudent> get filteredStudents {
    return allOutstandingStudents.where((student) {
      final matchesBatch = selectedBatchFilter.value == 'ALL' || student.batchCode == selectedBatchFilter.value;
      final q = searchQuery.value.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          student.studentName.toLowerCase().contains(q) ||
          student.rollNo.toLowerCase().contains(q) ||
          student.batchCode.toLowerCase().contains(q);
      return matchesBatch && matchesSearch;
    }).toList();
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }

  void selectBatch(String batch) {
    selectedBatchFilter.value = batch;
  }

  void updateSearch(String query) {
    searchQuery.value = query;
  }

  void selectPeriod(String period) {
    selectedPeriod.value = period;
  }

  Future<void> sendWhatsAppReminder(OutstandingFeeStudent student) async {
    final message = Uri.encodeComponent(
      'Dear Parent, this is a gentle reminder from Alogyan Academy regarding the tuition fee of ₹${student.dueAmount} for ${student.studentName} (${student.batchCode}). Kindly clear via UPI or visit the center.',
    );
    final url = Uri.parse('https://wa.me/${student.guardianContact.replaceAll('+', '')}?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('WhatsApp Alert', 'Opening WhatsApp reminder for ${student.studentName}');
    }
  }

  void recordPaymentForStudent(OutstandingFeeStudent student) {
    allOutstandingStudents.removeWhere((s) => s.id == student.id);
    totalCollected.value += student.dueAmount;
    totalPending.value -= student.dueAmount;
    receiptsCount.value += 1;
    pendingStudentsCount.value = allOutstandingStudents.length;
    Get.snackbar(
      'Payment Recorded',
      '₹${student.dueAmount} successfully recorded for ${student.studentName}',
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
