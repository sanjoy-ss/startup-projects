import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../../../core/widgets/mascot_holding_sheet_wrapper.dart';
import '../controllers/auth_controller.dart';

class UserProfileModal extends StatelessWidget {
  const UserProfileModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const UserProfileModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final user = authController.currentUser.value;
      if (user == null) {
        return const SizedBox.shrink();
      }

      return MascotHoldingSheetWrapper(
        child: Container(
          decoration: const BoxDecoration(
            color: AlogyanColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AlogyanColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Profile Header Card
            Row(
              children: [
                // Initials Circle
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AlogyanColors.primaryLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AlogyanColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        fontSize: 20,
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
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
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
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AlogyanColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.roleDisplay,
                              style: const TextStyle(
                                fontSize: 9,
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
                      Text(
                        user.instituteName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AlogyanColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(color: AlogyanColors.border, height: 1),
            const SizedBox(height: 16),

            // Contact Information
            _buildInfoRow(LucideIcons.mail, 'Institutional Email', user.email),
            const SizedBox(height: 10),
            _buildInfoRow(LucideIcons.phone, 'Mobile Verification', user.phone),
            const SizedBox(height: 10),
            _buildInfoRow(
              LucideIcons.bookOpen,
              'Assigned Subjects',
              user.subject,
            ),

            const SizedBox(height: 20),

            // Campus / Branch Switcher
            const Text(
              'ACTIVE CAMPUS / BRANCH',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: AlogyanColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),

            // Available Branches
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildBranchChip(
                  authController: authController,
                  branchId: 'main-campus',
                  branchName: 'Main Campus',
                  isActive: user.activeBranchId == 'main-campus',
                ),
                _buildBranchChip(
                  authController: authController,
                  branchId: 'north-branch',
                  branchName: 'North Campus',
                  isActive: user.activeBranchId == 'north-branch',
                ),
                _buildBranchChip(
                  authController: authController,
                  branchId: 'south-campus',
                  branchName: 'South Campus',
                  isActive: user.activeBranchId == 'south-campus',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Institution & Account Details
            const Text(
              'INSTITUTE & ACCOUNT METRICS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: AlogyanColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AlogyanColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AlogyanColors.border),
              ),
              child: Column(
                children: [
                  _buildInfoRow(LucideIcons.building, 'Tenant / Institute ID', user.instituteId),
                  const SizedBox(height: 8),
                  _buildInfoRow(LucideIcons.shieldCheck, 'Access Tier', user.roleDisplay),
                  const SizedBox(height: 8),
                  _buildInfoRow(LucideIcons.checkCircle, 'Account Status', user.status.toUpperCase()),
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
                  'Sign Out from Companion App',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AlogyanColors.danger,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AlogyanColors.dangerLight,
                    width: 1.5,
                  ),
                  backgroundColor: AlogyanColors.dangerLight.withValues(
                    alpha: 0.3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  });
}

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AlogyanColors.textSecondary),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AlogyanColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AlogyanColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildBranchChip({
    required AuthController authController,
    required String branchId,
    required String branchName,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () {
        authController.switchBranch(branchId, branchName);
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AlogyanColors.primary : AlogyanColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? AlogyanColors.primary : AlogyanColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? LucideIcons.checkCircle : LucideIcons.mapPin,
              size: 14,
              color: isActive ? Colors.white : AlogyanColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              branchName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.white : AlogyanColors.textPrimary,
              ),
            ),
          ],
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
              Navigator.of(ctx).pop(); // close dialog
              Navigator.of(context).pop(); // close modal sheet
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
