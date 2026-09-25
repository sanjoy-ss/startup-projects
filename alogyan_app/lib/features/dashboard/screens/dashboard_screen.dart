import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/alogyan_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../attendance/screens/quick_attendance_screen.dart';
import '../../fees/screens/quick_fee_screen.dart';
import '../../navigation/controllers/navigation_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _navigateToTabOrScreen(BuildContext context, int tabIndex, Widget screen) {
    if (Get.isRegistered<NavigationController>()) {
      Get.find<NavigationController>().changeTab(tabIndex);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Alogyan Academy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Prof. Sanjoy • Physics & Maths', style: TextStyle(fontSize: 12, color: AlogyanColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stat Tiles
            Row(
              children: [
                Expanded(
                  child: AlogyanCard(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Today Classes', style: TextStyle(fontSize: 12, color: AlogyanColors.textSecondary)),
                        SizedBox(height: 4),
                        Text('3 Batches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AlogyanColors.primary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AlogyanCard(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Pending Dues', style: TextStyle(fontSize: 12, color: AlogyanColors.textSecondary)),
                        SizedBox(height: 4),
                        Text('₹12,500', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AlogyanColors.danger)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Classroom Action Bar
            const Text(
              'Classroom Floor Actions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AlogyanColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AlogyanColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(LucideIcons.userCheck, size: 18),
                    label: const Text('Take Attendance', style: TextStyle(fontSize: 13)),
                    onPressed: () => _navigateToTabOrScreen(context, 1, const QuickAttendanceScreen()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AlogyanColors.textPrimary,
                      side: const BorderSide(color: AlogyanColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(LucideIcons.indianRupee, size: 18),
                    label: const Text('Collect Fee', style: TextStyle(fontSize: 13)),
                    onPressed: () => _navigateToTabOrScreen(context, 2, const QuickFeeScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Today's Timeline
            const Text(
              "Today's Schedule",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AlogyanColors.textPrimary),
            ),
            const SizedBox(height: 12),

            _buildClassCard(
              context,
              time: '04:00 PM - 05:30 PM',
              batchName: 'Class 10 - Advanced Physics',
              roomOrMeet: 'Room 201 (Offline)',
              status: 'NEXT CLASS',
              statusType: StatusBadgeType.warning,
            ),
            const SizedBox(height: 12),
            _buildClassCard(
              context,
              time: '06:00 PM - 07:30 PM',
              batchName: 'Class 12 - Calculus Masterclass',
              roomOrMeet: 'Google Meet (1-tap start)',
              status: 'ONLINE',
              statusType: StatusBadgeType.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context, {
    required String time,
    required String batchName,
    required String roomOrMeet,
    required String status,
    required StatusBadgeType statusType,
  }) {
    return AlogyanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AlogyanColors.textSecondary)),
              StatusBadge(label: status, type: statusType),
            ],
          ),
          const SizedBox(height: 8),
          Text(batchName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AlogyanColors.textPrimary)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(LucideIcons.mapPin, size: 14, color: AlogyanColors.textMuted),
              const SizedBox(width: 4),
              Text(roomOrMeet, style: const TextStyle(fontSize: 13, color: AlogyanColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
