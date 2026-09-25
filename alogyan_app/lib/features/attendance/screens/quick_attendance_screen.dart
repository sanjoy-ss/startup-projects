import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/primary_button.dart';

class QuickAttendanceScreen extends StatefulWidget {
  const QuickAttendanceScreen({super.key});

  @override
  State<QuickAttendanceScreen> createState() => _QuickAttendanceScreenState();
}

class _QuickAttendanceScreenState extends State<QuickAttendanceScreen> {
  final List<Map<String, dynamic>> _students = [
    {'id': '1', 'name': 'Aarav Sharma', 'roll': '101', 'status': 'present'},
    {'id': '2', 'name': 'Diya Sen', 'roll': '102', 'status': 'present'},
    {'id': '3', 'name': 'Ishaan Roy', 'roll': '103', 'status': 'absent'},
    {'id': '4', 'name': 'Meera Patel', 'roll': '104', 'status': 'present'},
    {'id': '5', 'name': 'Rohan Das', 'roll': '105', 'status': 'present'},
  ];

  void _toggleStatus(int index) {
    setState(() {
      final current = _students[index]['status'];
      if (current == 'present') {
        _students[index]['status'] = 'absent';
      } else if (current == 'absent') {
        _students[index]['status'] = 'late';
      } else {
        _students[index]['status'] = 'present';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _students.where((s) => s['status'] == 'present').length;
    final total = _students.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapid Attendance (Class 10 Physics)'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AlogyanColors.surfaceMuted,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$presentCount / $total Present', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (final s in _students) {
                        s['status'] = 'present';
                      }
                    });
                  },
                  child: const Text('Mark All Present'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _students.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: AlogyanColors.border),
              itemBuilder: (context, index) {
                final student = _students[index];
                final status = student['status'] as String;

                Color badgeBg = AlogyanColors.successLight;
                Color badgeFg = AlogyanColors.success;
                if (status == 'absent') {
                  badgeBg = AlogyanColors.dangerLight;
                  badgeFg = AlogyanColors.danger;
                } else if (status == 'late') {
                  badgeBg = AlogyanColors.warningLight;
                  badgeFg = AlogyanColors.warning;
                }

                return ListTile(
                  title: Text(student['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Roll #${student['roll']}'),
                  trailing: InkWell(
                    onTap: () => _toggleStatus(index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 90,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(color: badgeFg, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Submit Attendance ($presentCount/$total)',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Attendance submitted & queued offline')),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
