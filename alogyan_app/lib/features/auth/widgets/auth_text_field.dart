import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/colors.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? prefix;
  final Widget? suffixIcon;
  final String? helperText;
  final String? errorText;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final Widget? trailingLabelAction;
  final bool autofocus;

  const AuthTextField({
    super.key,
    required this.label,
    this.hintText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.helperText,
    this.errorText,
    this.inputFormatters,
    this.onChanged,
    this.onEditingComplete,
    this.trailingLabelAction,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AlogyanColors.textPrimary,
                letterSpacing: -0.1,
              ),
            ),
            ?trailingLabelAction,
          ],
        ),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: AlogyanColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            obscureText: obscureText,
            autofocus: autofocus,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            onEditingComplete: onEditingComplete,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AlogyanColors.textPrimary,
              letterSpacing: 0.1,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: AlogyanColors.textMuted,
                fontWeight: FontWeight.normal,
              ),
              prefixIcon: prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 16, right: 4),
                      child: prefixIcon,
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              prefix: prefix,
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              filled: true,
              fillColor: AlogyanColors.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: errorText != null && errorText!.isNotEmpty
                      ? AlogyanColors.danger
                      : AlogyanColors.border,
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: errorText != null && errorText!.isNotEmpty
                      ? AlogyanColors.danger
                      : AlogyanColors.primary,
                  width: 1.8,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AlogyanColors.danger,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AlogyanColors.danger,
                  width: 1.8,
                ),
              ),
            ),
          ),
        ),
        if (errorText != null && errorText!.isNotEmpty) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                fontSize: 12,
                color: AlogyanColors.danger,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              helperText!,
              style: const TextStyle(
                fontSize: 11,
                color: AlogyanColors.textSecondary,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
