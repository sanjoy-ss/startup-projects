import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../../../shared/widgets/status_badge.dart';
import '../controllers/students_controller.dart';

class StudentProfileModal extends StatefulWidget {
  final StudentItem student;

  const StudentProfileModal({
    super.key,
    required this.student,
  });

  static void show(BuildContext context, StudentItem student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StudentProfileModal(student: student),
    );
  }

  @override
  State<StudentProfileModal> createState() => _StudentProfileModalState();
}

class _StudentProfileModalState extends State<StudentProfileModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _batchController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dueController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _batchController = TextEditingController(text: widget.student.batch);
    _phoneController = TextEditingController(text: widget.student.phone);
    _dueController = TextEditingController(text: widget.student.dueAmount.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _batchController.dispose();
    _phoneController.dispose();
    _dueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentsController>();
    final hasDue = widget.student.dueAmount > 0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AlogyanColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AlogyanColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Student Profile',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AlogyanColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Student Identity Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AlogyanColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AlogyanColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AlogyanColors.primaryLight,
                      child: Text(
                        widget.student.name.isNotEmpty
                            ? widget.student.name.substring(0, 1).toUpperCase()
                            : 'S',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AlogyanColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.student.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AlogyanColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Batch: ${widget.student.batch}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AlogyanColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          StatusBadge(
                            label: hasDue
                                ? 'Due Balance: ₹${widget.student.dueAmount}'
                                : 'All Dues Paid',
                            type: hasDue
                                ? StatusBadgeType.danger
                                : StatusBadgeType.success,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Quick Actions: Call & WhatsApp
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.makeCall(widget.student.phone),
                      icon: const Icon(LucideIcons.phone, size: 16, color: AlogyanColors.info),
                      label: const Text('Call', style: TextStyle(color: AlogyanColors.info, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AlogyanColors.info),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.sendWhatsApp(widget.student.phone, widget.student.name),
                      icon: const Icon(LucideIcons.messageCircle, size: 16, color: AlogyanColors.success),
                      label: const Text('WhatsApp', style: TextStyle(color: AlogyanColors.success, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AlogyanColors.success),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Toggle Edit Mode / Change Profile button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? 'EDIT PROFILE DETAILS' : 'PROFILE DETAILS',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AlogyanColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      setState(() {
                        _isEditing = !_isEditing;
                      });
                    },
                    icon: Icon(
                      _isEditing ? LucideIcons.x : LucideIcons.userPen,
                      size: 14,
                      color: AlogyanColors.primary,
                    ),
                    label: Text(
                      _isEditing ? 'Cancel Edit' : 'Change Profile',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AlogyanColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (!_isEditing) ...[
                // View Mode
                _buildInfoTile(LucideIcons.user, 'Full Name', widget.student.name),
                const SizedBox(height: 8),
                _buildInfoTile(LucideIcons.bookOpen, 'Enrolled Batch', widget.student.batch),
                const SizedBox(height: 8),
                _buildInfoTile(LucideIcons.phone, 'Phone Number', widget.student.phone),
                const SizedBox(height: 8),
                _buildInfoTile(LucideIcons.indianRupee, 'Pending Due', '₹${widget.student.dueAmount}'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isEditing = true;
                      });
                    },
                    icon: const Icon(LucideIcons.userPen, size: 16),
                    label: const Text('Change Student Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AlogyanColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Edit Mode Form
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Student Name',
                    prefixIcon: const Icon(LucideIcons.user, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _batchController,
                  decoration: InputDecoration(
                    labelText: 'Batch Name',
                    prefixIcon: const Icon(LucideIcons.bookOpen, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: const Icon(LucideIcons.phone, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _dueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Due Amount (₹)',
                    prefixIcon: const Icon(LucideIcons.indianRupee, size: 18),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final newName = _nameController.text.trim();
                      if (newName.isEmpty) return;

                      final dueVal = int.tryParse(_dueController.text.trim()) ?? widget.student.dueAmount;
                      await controller.updateStudentProfile(
                        studentId: widget.student.id,
                        name: newName,
                        batch: _batchController.text.trim(),
                        phone: _phoneController.text.trim(),
                        dueAmount: dueVal,
                      );

                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    icon: const Icon(LucideIcons.check, size: 18),
                    label: const Text(
                      'Save Profile Changes',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AlogyanColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AlogyanColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AlogyanColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AlogyanColors.textSecondary),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AlogyanColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AlogyanColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
