import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/core/constants/colors.dart';
import 'package:alogyan_app/core/constants/styles.dart';

void main() {
  group('AlogyanColors', () {
    test('brand colors match specification tokens', () {
      expect(AlogyanColors.primary, const Color(0xFFD32F2F));
      expect(AlogyanColors.primaryDark, const Color(0xFF9A0007));
      expect(AlogyanColors.primaryLight, const Color(0xFFFFEBEE));
      expect(AlogyanColors.background, const Color(0xFFF8FAFC));
      expect(AlogyanColors.surface, Colors.white);
      expect(AlogyanColors.border, const Color(0xFFE2E8F0));
      expect(AlogyanColors.textPrimary, const Color(0xFF0F172A));
      expect(AlogyanColors.textSecondary, const Color(0xFF64748B));
      expect(AlogyanColors.success, const Color(0xFF16A34A));
      expect(AlogyanColors.danger, const Color(0xFFDC2626));
      expect(AlogyanColors.warning, const Color(0xFFD97706));
    });
  });

  group('AlogyanStyles', () {
    test('touch target conforms to 48dp minimum', () {
      expect(AlogyanStyles.minTouchTargetSize.width, greaterThanOrEqualTo(48.0));
      expect(AlogyanStyles.minTouchTargetSize.height, greaterThanOrEqualTo(48.0));
      expect(AlogyanStyles.cardRadius, BorderRadius.circular(12.0));
    });
  });
}
