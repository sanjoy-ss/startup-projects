import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../controllers/auth_controller.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;

    if (authController == null) {
      return const Center(
        child: Text(
          'Authentication service not initialized',
          style: TextStyle(color: AlogyanColors.textSecondary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AlogyanColors.background,
      body: Obx(() {
        final user = authController.currentUser.value;
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(color: AlogyanColors.primary),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Profile Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AlogyanColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AlogyanColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Initials Avatar
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AlogyanColors.primaryLight,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AlogyanColors.primary.withValues(
                                alpha: 0.25,
                              ),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user.initials,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AlogyanColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: AlogyanColors.textPrimary,
                                        letterSpacing: -0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AlogyanColors.primaryLight,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      user.roleDisplay,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        color: AlogyanColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                user.designation,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AlogyanColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${user.instituteName} • ${user.activeBranchName}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AlogyanColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 42,
                      child: ElevatedButton.icon(
                        onPressed: () => _openEditProfileSheet(
                          context,
                          authController,
                          user,
                        ),
                        icon: const Icon(LucideIcons.userPen, size: 16),
                        label: const Text(
                          'Edit Profile Details',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AlogyanColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Contact & Educator Information
              _buildSectionHeader('EDUCATOR CREDENTIALS'),
              Container(
                decoration: BoxDecoration(
                  color: AlogyanColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AlogyanColors.border),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    _buildCredentialRow(
                      LucideIcons.mail,
                      'Email Address',
                      user.email,
                    ),
                    const Divider(color: AlogyanColors.border, height: 16),
                    _buildCredentialRow(
                      LucideIcons.phone,
                      'Phone Number',
                      user.phone.isNotEmpty ? user.phone : 'Not Specified',
                    ),
                    const Divider(color: AlogyanColors.border, height: 16),
                    _buildCredentialRow(
                      LucideIcons.bookOpen,
                      'Assigned Subjects',
                      user.subject.isNotEmpty
                          ? user.subject
                          : 'General Faculty',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Campus / Branch Switcher
              // _buildSectionHeader('ACTIVE CAMPUS / BRANCH'),
              // Wrap(
              //   spacing: 10,
              //   runSpacing: 10,
              //   children: [
              //     _buildBranchOption(
              //       authController: authController,
              //       branchId: 'main-campus',
              //       name: 'Main Campus',
              //       isActive: user.activeBranchId == 'main-campus',
              //     ),
              //     _buildBranchOption(
              //       authController: authController,
              //       branchId: 'north-branch',
              //       name: 'North Campus',
              //       isActive: user.activeBranchId == 'north-branch',
              //     ),
              //     _buildBranchOption(
              //       authController: authController,
              //       branchId: 'south-campus',
              //       name: 'South Campus',
              //       isActive: user.activeBranchId == 'south-campus',
              //     ),
              //   ],
              // ),
              const SizedBox(height: 20),

              // Institute & Tenant Metrics
              _buildSectionHeader('INSTITUTE & SYSTEM INFO'),
              Container(
                decoration: BoxDecoration(
                  color: AlogyanColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AlogyanColors.border),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  children: [
                    _buildCredentialRow(
                      LucideIcons.building,
                      'Tenant / Institute ID',
                      user.instituteId,
                    ),
                    const Divider(color: AlogyanColors.border, height: 16),
                    _buildCredentialRow(
                      LucideIcons.shieldCheck,
                      'Access Tier',
                      user.roleDisplay,
                    ),
                    const Divider(color: AlogyanColors.border, height: 16),
                    _buildCredentialRow(
                      LucideIcons.checkCircle,
                      'Account Status',
                      user.status.toUpperCase(),
                    ),
                    const Divider(color: AlogyanColors.border, height: 16),
                    _buildCredentialRow(
                      LucideIcons.database,
                      'Local Cache Engine',
                      'Hive Encrypted Box (Offline Ready)',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Sign Out Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => _confirmSignOut(context, authController),
                  icon: const Icon(
                    LucideIcons.logOut,
                    size: 18,
                    color: AlogyanColors.danger,
                  ),
                  label: const Text(
                    'Sign Out from Alogyan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AlogyanColors.danger,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AlogyanColors.dangerLight,
                      width: 1.5,
                    ),
                    backgroundColor: AlogyanColors.dangerLight.withValues(
                      alpha: 0.25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
          color: AlogyanColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildCredentialRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AlogyanColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AlogyanColors.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
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
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _openEditProfileSheet(
    BuildContext context,
    AuthController authController,
    UserModel user,
  ) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    final desigCtrl = TextEditingController(text: user.designation);
    final subjectCtrl = TextEditingController(text: user.subject);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AlogyanColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Change Profile Details',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AlogyanColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20),
                    onPressed: () => Navigator.of(sheetCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: const Icon(LucideIcons.user, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Mobile Phone',
                  prefixIcon: const Icon(LucideIcons.phone, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: desigCtrl,
                decoration: InputDecoration(
                  labelText: 'Designation / Role',
                  prefixIcon: const Icon(LucideIcons.briefcase, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectCtrl,
                decoration: InputDecoration(
                  labelText: 'Assigned Subjects',
                  prefixIcon: const Icon(LucideIcons.bookOpen, size: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    await authController.updateProfile(
                      name: nameCtrl.text,
                      phone: phoneCtrl.text,
                      designation: desigCtrl.text,
                      subject: subjectCtrl.text,
                    );
                    if (sheetCtx.mounted) {
                      Navigator.of(sheetCtx).pop();
                    }
                  },
                  icon: const Icon(LucideIcons.check, size: 18),
                  label: const Text(
                    'Save Profile Changes',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out Confirmation',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to sign out from Alogyan Companion? Local cached data remains safe on this device.',
          style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AlogyanColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              authController.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AlogyanColors.danger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
