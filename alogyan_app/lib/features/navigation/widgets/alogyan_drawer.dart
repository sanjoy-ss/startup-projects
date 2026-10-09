import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/widgets/user_profile_modal.dart';
import '../../students/screens/students_screen.dart';
import '../controllers/navigation_controller.dart';

class AlogyanDrawer extends StatelessWidget {
  const AlogyanDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final navController = Get.isRegistered<NavigationController>()
        ? Get.find<NavigationController>()
        : Get.put(NavigationController());

    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;

    return Drawer(
      backgroundColor: AlogyanColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            _buildDrawerHeader(context, authController),

            const Divider(color: AlogyanColors.border, height: 1),

            // Navigation Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'MAIN NAVIGATION',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AlogyanColors.textSecondary,
                      ),
                    ),
                  ),
                  Obx(
                    () => _buildNavItem(
                      icon: LucideIcons.layoutDashboard,
                      label: 'Dashboard Overview',
                      isSelected: navController.currentIndex.value == 0,
                      onTap: () {
                        navController.changeTab(0);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => _buildNavItem(
                      icon: LucideIcons.bookOpen,
                      label: 'Batches & Classes',
                      isSelected: navController.currentIndex.value == 1,
                      onTap: () {
                        navController.changeTab(1);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => _buildNavItem(
                      icon: LucideIcons.indianRupee,
                      label: 'Fee Collection & UPI',
                      isSelected: navController.currentIndex.value == 2,
                      onTap: () {
                        navController.changeTab(2);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => _buildNavItem(
                      icon: LucideIcons.user,
                      label: 'Educator Profile',
                      isSelected: navController.currentIndex.value == 3,
                      onTap: () {
                        navController.changeTab(3);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildNavItem(
                    icon: LucideIcons.users,
                    label: 'Student Directory',
                    isSelected: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(
                              title: const Text(
                                'Student Directory',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AlogyanColors.textPrimary,
                                ),
                              ),
                              backgroundColor: AlogyanColors.surface,
                              elevation: 0,
                              iconTheme: const IconThemeData(color: AlogyanColors.textPrimary),
                              shape: const Border(
                                bottom: BorderSide(color: AlogyanColors.border, width: 1.0),
                              ),
                            ),
                            body: const StudentsScreen(),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: AlogyanColors.border, height: 1),
                  const SizedBox(height: 12),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'PROFILE & ACCOUNT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AlogyanColors.textSecondary,
                      ),
                    ),
                  ),
                  _buildNavItem(
                    icon: LucideIcons.userPen,
                    label: 'Change Profile',
                    isSelected: false,
                    onTap: () {
                      Navigator.of(context).pop();
                      UserProfileModal.show(context);
                    },
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: AlogyanColors.border, height: 1),
                  const SizedBox(height: 12),

                  // Campus / Branch Switcher in Drawer
                  if (authController != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Text(
                        'CAMPUS SWITCHER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AlogyanColors.textSecondary,
                        ),
                      ),
                    ),
                    Obx(() {
                      final user = authController.currentUser.value;
                      final activeBranch = user?.activeBranchId ?? 'main-campus';
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Column(
                          children: [
                            _buildBranchTile(
                              authController: authController,
                              branchId: 'main-campus',
                              name: 'Main Campus',
                              isActive: activeBranch == 'main-campus',
                            ),
                            const SizedBox(height: 4),
                            _buildBranchTile(
                              authController: authController,
                              branchId: 'north-branch',
                              name: 'North Campus',
                              isActive: activeBranch == 'north-branch',
                            ),
                            const SizedBox(height: 4),
                            _buildBranchTile(
                              authController: authController,
                              branchId: 'south-campus',
                              name: 'South Campus',
                              isActive: activeBranch == 'south-campus',
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),

            const Divider(color: AlogyanColors.border, height: 1),

            // Drawer Footer
            _buildDrawerFooter(context, authController),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context, AuthController? authController) {
    if (authController == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Text('Alogyan Companion', style: TextStyle(fontWeight: FontWeight.bold)),
      );
    }

    return Obx(() {
      final user = authController.currentUser.value;
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: const BoxDecoration(
          color: AlogyanColors.surface,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Institute Brand & Branch
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AlogyanColors.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'A',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AlogyanColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.instituteName ?? 'Alogyan Academy',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AlogyanColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'CAMPUS: ${user?.activeBranchName.toUpperCase() ?? "MAIN"}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AlogyanColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Profile Card (Tap to View / Change Profile)
            InkWell(
              onTap: () {
                Navigator.of(context).pop();
                UserProfileModal.show(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AlogyanColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AlogyanColors.border),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AlogyanColors.primaryLight,
                      child: Text(
                        user?.initials ?? 'A',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AlogyanColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user?.name ?? 'Educator',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AlogyanColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                LucideIcons.chevronRight,
                                size: 14,
                                color: AlogyanColors.textSecondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.subject.isNotEmpty == true
                                ? user!.subject
                                : (user?.designation ?? 'Faculty'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AlogyanColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? AlogyanColors.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: isSelected ? AlogyanColors.primary : AlogyanColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AlogyanColors.primary : AlogyanColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AlogyanColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranchTile({
    required AuthController authController,
    required String branchId,
    required String name,
    required bool isActive,
  }) {
    return InkWell(
      onTap: () => authController.switchBranch(branchId, name),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AlogyanColors.surfaceMuted : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AlogyanColors.primary.withValues(alpha: 0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? LucideIcons.checkCircle : LucideIcons.mapPin,
              size: 14,
              color: isActive ? AlogyanColors.primary : AlogyanColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AlogyanColors.primary : AlogyanColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerFooter(BuildContext context, AuthController? authController) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Alogyan Companion',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AlogyanColors.textPrimary,
                  ),
                ),
                Text(
                  'v1.0.0 • Offline Ready',
                  style: TextStyle(
                    fontSize: 10,
                    color: AlogyanColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (authController != null)
            IconButton(
              icon: const Icon(LucideIcons.logOut, size: 20, color: AlogyanColors.danger),
              tooltip: 'Sign Out',
              onPressed: () {
                Navigator.of(context).pop();
                _confirmSignOut(context, authController);
              },
            ),
        ],
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
            child: const Text('Cancel', style: TextStyle(color: AlogyanColors.textSecondary)),
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
