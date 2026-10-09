import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/alogyan_card.dart';
import '../models/dashboard_models.dart';
import 'join_live_class_screen.dart';
import 'whiteboard_screen.dart';

class ClassDetailsScreen extends StatelessWidget {
  final ScheduledClassItem? classItem;

  const ClassDetailsScreen({super.key, this.classItem});

  @override
  Widget build(BuildContext context) {
    final title = classItem?.title ?? 'Flutter Layouts and Responsive UI';
    final batch = classItem?.batchCode ?? 'FL-01';
    final time = classItem?.timeRange ?? '6:00 PM – 7:00 PM';
    final isOnline = classItem?.isOnline ?? true;

    return Scaffold(
      backgroundColor: AlogyanColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Class Details',
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
            icon: const Icon(LucideIcons.copy, size: 18, color: AlogyanColors.textSecondary),
            tooltip: 'Copy Class Link',
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: 'https://meet.google.com/alo-gyan-xyz'));
              Get.snackbar('Copied', 'Class meeting link copied to clipboard', snackPosition: SnackPosition.BOTTOM);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status ribbon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AlogyanColors.successLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AlogyanColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        classItem?.status ?? 'Scheduled',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AlogyanColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$batch • Oct 6, 2026',
                  style: const TextStyle(fontSize: 12, color: AlogyanColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Class Header Card
            AlogyanCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text(
                        'LIVE SESSION',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AlogyanColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text('•', style: TextStyle(color: AlogyanColors.textSecondary)),
                      SizedBox(width: 6),
                      Text(
                        '60 Mins',
                        style: TextStyle(fontSize: 11.5, color: AlogyanColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AlogyanColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Flutter Foundations ($batch) • 24 Enrolled Students',
                    style: const TextStyle(fontSize: 12.5, color: AlogyanColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  // Session Details Block
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AlogyanColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _buildDetailRow(
                          icon: LucideIcons.calendar,
                          title: 'Tuesday, 6 October 2026',
                          subtitle: '$time (Asia/Kolkata)',
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          icon: isOnline ? LucideIcons.video : LucideIcons.mapPin,
                          title: isOnline ? 'Google Meet Online (HD Video)' : 'Room 204, Agartala Campus',
                          subtitle: isOnline ? 'sanjoy.sarkar@alogyan.ac.in' : 'Offline In-Person Lecture',
                        ),
                        const SizedBox(height: 10),
                        _buildDetailRow(
                          icon: LucideIcons.user,
                          title: 'Sanjoy Sarkar',
                          subtitle: 'Lead Educator • Mobile Engineering',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => const JoinLiveClassScreen()),
                    icon: const Icon(LucideIcons.play, size: 16),
                    label: const Text('Start / Launch Session'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AlogyanColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Get.to(() => const WhiteboardScreen()),
                          icon: const Icon(LucideIcons.penTool, size: 15),
                          label: const Text('Whiteboard'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AlogyanColors.textPrimary,
                            side: const BorderSide(color: AlogyanColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Get.snackbar('Curriculum Handout', 'Sharing starter files with enrolled students');
                          },
                          icon: const Icon(LucideIcons.share2, size: 15),
                          label: const Text('Share Notes'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AlogyanColors.textPrimary,
                            side: const BorderSide(color: AlogyanColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Curriculum Topic Objectives
            const Text(
              'Session Agenda & Objectives',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AlogyanColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            AlogyanCard(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _buildAgendaItem('1', 'Flutter Rendering Pipeline & Viewport constraints'),
                  const SizedBox(height: 8),
                  _buildAgendaItem('2', 'Row, Column, Expanded vs Flexible touch zones'),
                  const SizedBox(height: 8),
                  _buildAgendaItem('3', 'LayoutBuilder & Responsive Breakpoints'),
                  const SizedBox(height: 8),
                  _buildAgendaItem('4', 'Live Coding: Responsive Teacher Dashboard UI'),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Enrolled Students Quick Roster
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Enrolled Students (24)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AlogyanColors.textPrimary,
                  ),
                ),
                Text(
                  '14 in Lobby',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AlogyanColors.success),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AlogyanCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                children: [
                  _buildStudentRow('Riya Das', 'FL-001', 'In Lobby', true),
                  const Divider(height: 14, color: AlogyanColors.border),
                  _buildStudentRow('Subhasish Ghosh', 'FL-012', 'In Lobby', true),
                  const Divider(height: 14, color: AlogyanColors.border),
                  _buildStudentRow('Tanmoy Sen', 'FL-019', 'Offline', false),
                  const Divider(height: 14, color: AlogyanColors.border),
                  _buildStudentRow('Debabrata Das', 'FL-022', 'In Lobby', true),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required IconData icon, required String title, required String subtitle}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AlogyanColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AlogyanColors.textPrimary),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11.5, color: AlogyanColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildAgendaItem(String number, String text) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AlogyanColors.surfaceMuted,
            borderRadius: BorderRadius.circular(4),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AlogyanColors.textSecondary),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: AlogyanColors.textPrimary),
          ),
        ),
      ],
    );
  }

  static Widget _buildStudentRow(String name, String roll, String status, bool inLobby) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AlogyanColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Text(
                  name[0],
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AlogyanColors.textPrimary, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AlogyanColors.textPrimary)),
                  Text(roll, style: const TextStyle(fontSize: 11, color: AlogyanColors.textSecondary)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: inLobby ? AlogyanColors.successLight : AlogyanColors.surfaceMuted,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: inLobby ? AlogyanColors.success : AlogyanColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
