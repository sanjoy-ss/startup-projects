import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../core/widgets/mascot_holding_sheet_wrapper.dart';
import '../models/user_model.dart';

class QuickDemoLoginSheet extends StatelessWidget {
  final Function(UserModel) onSelectDemo;

  const QuickDemoLoginSheet({
    super.key,
    required this.onSelectDemo,
  });

  /// Opens the full demo profiles bottom sheet
  static void show(BuildContext context, Function(UserModel) onSelect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DemoProfilesModal(onSelectDemo: (user) {
        Navigator.pop(ctx);
        onSelect(user);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () => show(context, onSelectDemo),
        icon: const Icon(LucideIcons.sparkles, size: 14, color: AlogyanColors.primary),
        label: const Text(
          'Explore with Demo Account',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AlogyanColors.textSecondary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          side: const BorderSide(color: AlogyanColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: AlogyanColors.surface,
          elevation: 0,
        ),
      ),
    );
  }
}

class _DemoProfilesModal extends StatelessWidget {
  final Function(UserModel) onSelectDemo;

  const _DemoProfilesModal({required this.onSelectDemo});

  @override
  Widget build(BuildContext context) {
    return MascotHoldingSheetWrapper(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: const BoxDecoration(
          color: AlogyanColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AlogyanColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: const [
                Icon(LucideIcons.shieldCheck, size: 20, color: AlogyanColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Demo Educator Accounts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AlogyanColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Select a preset role to explore companion app workflows:',
              style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ...UserModel.demoProfiles.map((profile) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildModalTile(profile),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildModalTile(UserModel profile) {
    Color badgeBg = profile.isOwner
        ? AlogyanColors.primaryLight
        : (profile.isTeacher ? AlogyanColors.infoLight : AlogyanColors.successLight);
    Color badgeText = profile.isOwner
        ? AlogyanColors.primary
        : (profile.isTeacher ? AlogyanColors.info : AlogyanColors.success);

    return Material(
      color: AlogyanColors.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => onSelectDemo(profile),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    profile.initials,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: badgeText,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AlogyanColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            profile.roleDisplay,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: badgeText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${profile.subject} • ${profile.activeBranchName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AlogyanColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.arrowRight, size: 16, color: AlogyanColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
