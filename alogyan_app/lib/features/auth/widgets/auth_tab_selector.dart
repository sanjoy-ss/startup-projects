import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';

class AuthTabSelector extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChanged;

  const AuthTabSelector({
    super.key,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AlogyanColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AlogyanColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem(
              id: 'phone',
              label: 'Mobile OTP',
              icon: LucideIcons.smartphone,
              isSelected: activeTab == 'phone',
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildTabItem(
              id: 'email',
              label: 'Email & Password',
              icon: LucideIcons.mail,
              isSelected: activeTab == 'email',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required String id,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTabChanged(id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AlogyanColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AlogyanColors.primary : AlogyanColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AlogyanColors.textPrimary : AlogyanColors.textSecondary,
                  letterSpacing: -0.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
