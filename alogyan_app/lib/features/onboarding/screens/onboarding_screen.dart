import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/constants/colors.dart';
import '../../../core/constants/onboarding_mascot_data.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OnboardingController>();

    final slides = [
      _OnboardingSlideData(
        index: 0,
        alignment: _SlideAlignment.centerMascot,
        stepNumber: '01',
        totalSteps: '03',
        category: 'ATTENDANCE',
        techBadge: 'Smart 1-Tap Roster',
        title: 'Attendance in\nten seconds flat.',
        description: 'Mark your entire batch in one tap, toggle absentees with ease, and dispatch WhatsApp alerts to parents instantly.',
        mascotBytes: OnboardingMascotData.attendanceBytes,
        accentColor: AlogyanColors.success,
      ),
      _OnboardingSlideData(
        index: 1,
        alignment: _SlideAlignment.centerMascot,
        stepNumber: '02',
        totalSteps: '03',
        category: 'SMART PAYMENTS',
        techBadge: 'Dynamic BHIM UPI',
        title: 'Tuition fees paid\nvia dynamic UPI.',
        description: 'Display student-specific UPI QR codes directly on your screen. No card machines, zero delays, and instant receipts.',
        mascotBytes: OnboardingMascotData.feesBytes,
        accentColor: AlogyanColors.warning,
      ),
      _OnboardingSlideData(
        index: 2,
        alignment: _SlideAlignment.centerMascot,
        stepNumber: '03',
        totalSteps: '03',
        category: 'OFFLINE FIRST',
        techBadge: '100% Offline Engine',
        title: 'Engineered for\nbasement classes.',
        description: 'Basements and weak signals will never stop class. Everything queues safely on your phone and syncs when reconnected.',
        mascotBytes: OnboardingMascotData.offlineBytes,
        accentColor: const Color(0xFF2563EB),
      ),
    ];

    final screenHeight = MediaQuery.of(context).size.height;
    final topWaveHeight = math.max(350.0, screenHeight * 0.48);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Stack(
          children: [
            // 1. Organic Red Wave Header (Covering top half for continuation with Login Screen)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topWaveHeight,
              child: AnimatedBuilder(
                animation: controller.pageController,
                builder: (context, _) {
                  double page = 0.0;
                  if (controller.pageController.hasClients &&
                      controller.pageController.position.haveDimensions) {
                    page =
                        controller.pageController.page ??
                        controller.currentPage.value.toDouble();
                  } else {
                    page = controller.currentPage.value.toDouble();
                  }
                  return CustomPaint(
                    painter: _OnboardingRedWavePainter(pageOffset: page),
                  );
                },
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Top App Bar with Alogyan emblem and discrete Skip
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Alogyan Brand Mark
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 1.2,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  LucideIcons.graduationCap,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: const [
                                    Text(
                                      'Alogyan',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    Text(
                                      '.',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFFFFCDD2),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.20),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'Educator Companion',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Minimalist Skip action with translucent pill button
                        Obx(() {
                          final isLast =
                              controller.currentPage.value ==
                              OnboardingController.totalPages - 1;
                          if (isLast) {
                            return const SizedBox(width: 48, height: 32);
                          }
                          return InkWell(
                            onTap: controller.finishOnboarding,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 1.0,
                                ),
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // Carousel Slides with Diverse Spatial Layouts (Right -> Left -> Center Climax)
                  Expanded(
                    child: PageView.builder(
                      controller: controller.pageController,
                      onPageChanged: controller.onPageChanged,
                      itemCount: slides.length,
                      itemBuilder: (context, index) {
                        return _OnboardingSlideWidget(data: slides[index]);
                      },
                    ),
                  ),

                  // Continuous Bottom Dock: Left Segmented Progress + Right Primary Action
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 8, 28, 26),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Segmented Step Indicator Bars
                        Row(
                          children: List.generate(
                            slides.length,
                            (index) => Obx(() {
                              final isActive =
                                  controller.currentPage.value == index;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 320),
                                curve: Curves.easeOutCubic,
                                margin: const EdgeInsets.only(right: 6),
                                height: 4,
                                width: isActive ? 34 : 12,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AlogyanColors.primary
                                      : AlogyanColors.border,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              );
                            }),
                          ),
                        ),

                        // Primary Action Button (Sleek floating pill)
                        Obx(() {
                          final isLast =
                              controller.currentPage.value == slides.length - 1;
                          return ElevatedButton(
                            onPressed: controller.nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AlogyanColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: AlogyanColors.primary.withValues(
                                alpha: 0.35,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isLast ? 'Get Started' : 'Continue',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isLast
                                      ? LucideIcons.arrowRight
                                      : LucideIcons.chevronRight,
                                  size: 16,
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _SlideAlignment {
  rightMascot, // Slide 1: Mascot Right, Text Left
  leftMascot, // Slide 2: Mascot Left, Text Right
  centerMascot, // Slide 3: Mascot Center, Grounding towards Login
}

class _OnboardingSlideData {
  final int index;
  final _SlideAlignment alignment;
  final String stepNumber;
  final String totalSteps;
  final String category;
  final String techBadge;
  final String title;
  final String description;
  final dynamic mascotBytes;
  final Color accentColor;

  const _OnboardingSlideData({
    required this.index,
    required this.alignment,
    required this.stepNumber,
    required this.totalSteps,
    required this.category,
    required this.techBadge,
    required this.title,
    required this.description,
    required this.mascotBytes,
    required this.accentColor,
  });
}

class _OnboardingSlideWidget extends StatelessWidget {
  final _OnboardingSlideData data;

  const _OnboardingSlideWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final heroHeight = math.min(availableHeight * 0.44, 280.0);
        final mascotSize = math.min(heroHeight * 0.88, 240.0);

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: availableHeight),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment:
                      data.alignment == _SlideAlignment.centerMascot
                      ? CrossAxisAlignment.center
                      : (data.alignment == _SlideAlignment.leftMascot
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start),
                  children: [
                    const SizedBox(height: 2),

                    // Dynamic Hero Stage positioned according to Slide Spatial Identity
                    SizedBox(
                      height: heroHeight,
                      width: double.infinity,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 1. Dynamic Free-Standing Action Mascot
                          if (data.alignment == _SlideAlignment.rightMascot)
                            Positioned(
                              right: 0,
                              top: heroHeight * 0.02,
                              child: _buildFreestandingMascot(mascotSize, data),
                            )
                          else if (data.alignment == _SlideAlignment.leftMascot)
                            Positioned(
                              left: 0,
                              top: heroHeight * 0.02,
                              child: _buildFreestandingMascot(mascotSize, data),
                            )
                          else
                            Positioned.fill(
                              child: Center(
                                child: _buildFreestandingMascot(
                                  mascotSize,
                                  data,
                                ),
                              ),
                            ),

                          // 2. Interactive Floating Tech Status Badge
                          if (data.alignment == _SlideAlignment.rightMascot)
                            Positioned(
                              left: 0,
                              bottom: heroHeight * 0.10,
                              child: _buildTechBadge(data),
                            )
                          else if (data.alignment == _SlideAlignment.leftMascot)
                            Positioned(
                              right: 0,
                              bottom: heroHeight * 0.10,
                              child: _buildTechBadge(data),
                            )
                          else
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Center(child: _buildTechBadge(data)),
                            ),
                        ],
                      ),
                    ),

                    // Clean Editorial Step Marker
                    _buildStepMarker(data),

                    // Editorial Headline (Respects Alignment)
                    Text(
                      data.title,
                      textAlign: data.alignment == _SlideAlignment.centerMascot
                          ? TextAlign.center
                          : (data.alignment == _SlideAlignment.leftMascot
                                ? TextAlign.right
                                : TextAlign.left),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: availableHeight < 520 ? 22 : 27,
                        fontWeight: FontWeight.w800,
                        color: AlogyanColors.textPrimary,
                        height: 1.18,
                        letterSpacing: -0.7,
                      ),
                    ),

                    // Clear Subtitle (Respects Alignment)
                    Text(
                      data.description,
                      textAlign: data.alignment == _SlideAlignment.centerMascot
                          ? TextAlign.center
                          : (data.alignment == _SlideAlignment.leftMascot
                                ? TextAlign.right
                                : TextAlign.left),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: availableHeight < 520 ? 13 : 14.5,
                        fontWeight: FontWeight.w400,
                        color: AlogyanColors.textSecondary,
                        height: 1.55,
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepMarker(_OnboardingSlideData data) {
    if (data.alignment == _SlideAlignment.centerMascot) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 1.5,
            decoration: BoxDecoration(
              color: AlogyanColors.primary.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${data.stepNumber} / ${data.totalSteps}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AlogyanColors.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 24,
            height: 1.5,
            decoration: BoxDecoration(
              color: AlogyanColors.primary.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      );
    } else if (data.alignment == _SlideAlignment.leftMascot) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 24,
            height: 1.5,
            decoration: BoxDecoration(
              color: AlogyanColors.primary.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${data.stepNumber} / ${data.totalSteps}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AlogyanColors.primary,
              letterSpacing: 1.5,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Text(
            '${data.stepNumber} / ${data.totalSteps}',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AlogyanColors.primary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 24,
            height: 1.5,
            decoration: BoxDecoration(
              color: AlogyanColors.primary.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildFreestandingMascot(
    double mascotSize,
    _OnboardingSlideData data,
  ) {
    return SizedBox(
      width: mascotSize,
      height: mascotSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft ambient backlight stage for high contrast and 3D depth on red wave
          SizedBox(
            width: mascotSize * 0.82,
            height: mascotSize * 0.82,
          ),
          Image.memory(data.mascotBytes, fit: BoxFit.contain),
        ],
      ),
    );
  }

  Widget _buildTechBadge(_OnboardingSlideData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: data.accentColor.withValues(alpha: 0.3),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: data.accentColor.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: data.accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            data.techBadge,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AlogyanColors.textPrimary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Organic Red Background Curve Wave Painter for Onboarding Screen
/// Smoothly morphs distinct, beautiful wave profiles across each slide via real-time lerp.
/// Built with mathematically collinear G1-continuous cubic Béziers for zero kinks or bumps.
/// Features high-visibility engineering textures (contour ribbons, dual-layer crest shimmer,
/// technical dot-matrix grid, orbit rings, and high-contrast page motifs).
class _OnboardingRedWavePainter extends CustomPainter {
  final double pageOffset;

  _OnboardingRedWavePainter({required this.pageOffset});

  /// Smooth 3-point interpolation helper across pageOffset (0.0 -> 1.0 -> 2.0)
  static double _lerp3(double a, double b, double c, double t) {
    if (t <= 1.0) {
      return ui.lerpDouble(a, b, t)!;
    } else {
      return ui.lerpDouble(b, c, t - 1.0)!;
    }
  }

  /// Builds a G1-continuous wave path using two collinear cubic Bézier spans
  /// Entering (0, y0) -> (xm, ym) -> (width, yEnd) with shared midpoint tangent (tanDx, tanDy)
  Path _buildWavePath({
    required double y0,
    required double c1x,
    required double c1y,
    required double xm,
    required double ym,
    required double tanDx,
    required double tanDy,
    required double c4x,
    required double c4y,
    required double yEnd,
    required double width,
    double yOffset = 0.0,
  }) {
    final path = Path();
    path.moveTo(0, y0 + yOffset);
    path.cubicTo(
      c1x,
      c1y + yOffset,
      xm - tanDx,
      ym - tanDy + yOffset,
      xm,
      ym + yOffset,
    );
    path.cubicTo(
      xm + tanDx,
      ym + tanDy + yOffset,
      c4x,
      c4y + yOffset,
      width,
      yEnd + yOffset,
    );
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final t = pageOffset.clamp(0.0, 2.0);

    // 1. Vibrant Alogyan Brand Red Linear Gradient
    final wavePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFE53935), // Alogyan vibrant red
          Color(0xFFB71C1C), // Deep crimson
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    // Subtle parallax tracking synced to finger gesture
    final parallaxShift = (pageOffset - 1.0) * (size.width * 0.035);

    // 2. Collinear G1-Continuous Cubic Bézier Wave Parameters
    // Page 0 (Attendance / Dynamic Coaching): Energetic swoop down-right
    // Page 1 (UPI / Fees): Double fluid harmonic S-curve
    // Page 2 (Offline First Engine / Launch): Grounded bedrock curve aligned with LoginScreen
    final y0 = _lerp3(0.74, 0.82, 0.76, t) * size.height;
    final c1x = (_lerp3(0.20, 0.18, 0.22, t) * size.width + parallaxShift * 0.9)
        .clamp(0.0, size.width);
    final c1y = _lerp3(0.90, 0.72, 0.88, t) * size.height;

    final xm = (_lerp3(0.52, 0.50, 0.54, t) * size.width + parallaxShift * 0.5)
        .clamp(0.0, size.width);
    final ym = _lerp3(0.82, 0.86, 0.82, t) * size.height;

    final tanDx = _lerp3(0.18, 0.16, 0.18, t) * size.width;
    final tanDy = _lerp3(-0.04, 0.04, -0.03, t) * size.height;

    final c4x = (_lerp3(0.84, 0.82, 0.85, t) * size.width + parallaxShift * 0.3)
        .clamp(0.0, size.width);
    final c4y = _lerp3(0.74, 0.92, 0.73, t) * size.height;
    final yEnd = _lerp3(0.82, 0.76, 0.84, t) * size.height;

    // Primary Wave Contour
    final waveLine = _buildWavePath(
      y0: y0,
      c1x: c1x,
      c1y: c1y,
      xm: xm,
      ym: ym,
      tanDx: tanDx,
      tanDy: tanDy,
      c4x: c4x,
      c4y: c4y,
      yEnd: yEnd,
      width: size.width,
    );

    // Filled Red Wave Body
    final filledPath = Path.from(waveLine)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(filledPath, wavePaint);

    // // 3. Technical Dot-Matrix Grid (High-finish subtle texture across red field)
    // final dotGridPaint = Paint()..color = Colors.white.withValues(alpha: 0.12);
    // const spacing = 24.0;
    // final gridOffsetX = (parallaxShift * 0.4) % spacing;
    // for (double x = gridOffsetX; x < size.width; x += spacing) {
    //   for (double y = 14.0; y < size.height * 0.70; y += spacing) {
    //     canvas.drawCircle(Offset(x, y), 1.1, dotGridPaint);
    //   }
    // }

    // 4. Highly Visible Multi-Layered Flowing Contour Ribbons
    // Ribbon 1: Secondary Accent Ribbon (Strong visibility, bold flow)
    final ribbon1 = _buildWavePath(
      y0: y0,
      c1x: c1x,
      c1y: c1y,
      xm: xm,
      ym: ym,
      tanDx: tanDx,
      tanDy: tanDy,
      c4x: c4x,
      c4y: c4y,
      yEnd: yEnd,
      width: size.width,
      yOffset: -28.0,
    );
    final ribbon1Paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.33)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(ribbon1, ribbon1Paint);

    // Ribbon 2: Tertiary Contour Ribbon (Mid-tone stratification)
    final ribbon2 = _buildWavePath(
      y0: y0,
      c1x: c1x,
      c1y: c1y,
      xm: xm,
      ym: ym,
      tanDx: tanDx,
      tanDy: tanDy,
      c4x: c4x,
      c4y: c4y,
      yEnd: yEnd,
      width: size.width,
      yOffset: -54.0,
    );
    final ribbon2Paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(ribbon2, ribbon2Paint);

    // Ribbon 3: Quaternary Fine Topographic Line (Delicate finish)
    final ribbon3 = _buildWavePath(
      y0: y0,
      c1x: c1x,
      c1y: c1y,
      xm: xm,
      ym: ym,
      tanDx: tanDx,
      tanDy: tanDy,
      c4x: c4x,
      c4y: c4y,
      yEnd: yEnd,
      width: size.width,
      yOffset: -78.0,
    );
    final ribbon3Paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.56)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(ribbon3, ribbon3Paint);

    // 5. Dual-Layer Luminous Crest Shimmer (Gleaming bottom wave edge)
    // Layer A: Outer Diffuse Glow
    final glowShimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.32),
          Colors.white.withValues(alpha: 0.48),
          Colors.white.withValues(alpha: 0.32),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(waveLine, glowShimmerPaint);

    // Layer B: Ultra-Crisp High-Luminance Core Line
    final coreShimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0.15),
          Colors.white.withValues(alpha: 0.70),
          Colors.white.withValues(alpha: 0.95),
          Colors.white.withValues(alpha: 0.70),
          Colors.white.withValues(alpha: 0.15),
        ],
        stops: const [0.0, 0.25, 0.50, 0.75, 1.0],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(waveLine, coreShimmerPaint);

    // 6. Ambient Mascot Stage Halo & Concentric Orbit Rings
    final glowX = size.width * (0.50 + (pageOffset - 1.0) * 0.16);
    final glowCenter = Offset(glowX, size.height * 0.42);

    final glowPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.22),
              Colors.white.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: glowCenter, radius: size.width * 0.44),
          );
    canvas.drawCircle(glowCenter, size.width * 0.44, glowPaint);

    // Orbit Rings: Inner, Middle, Outer
    final orbit1 = Paint()
      ..color = Colors.white.withValues(alpha: 0.32)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawCircle(glowCenter, 68, orbit1);

    final orbit2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawCircle(glowCenter, 112, orbit2);

    final orbit3 = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    canvas.drawCircle(glowCenter, 158, orbit3);

    // 7. Page-Specific Thematic Motifs (High Contrast & Clear Details)
    final w0 = (1.0 - (t - 0.0).abs()).clamp(0.0, 1.0);
    final w1 = (1.0 - (t - 1.0).abs()).clamp(0.0, 1.0);
    final w2 = (1.0 - (t - 2.0).abs()).clamp(0.0, 1.0);

    // Slide 0 Motif: Daily Attendance Ledger Ticks & Checkmark
    if (w0 > 0.02) {
      final p0DotPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45 * w0);
      final p0LinePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35 * w0)
        ..strokeWidth = 2.2
        ..strokeCap = StrokeCap.round;

      // 3 Status Rows
      canvas.drawCircle(
        Offset(size.width * 0.16, size.height * 0.32),
        3.2,
        p0DotPaint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.16, size.height * 0.39),
        3.2,
        p0DotPaint,
      );
      canvas.drawCircle(
        Offset(size.width * 0.16, size.height * 0.46),
        3.2,
        p0DotPaint,
      );

      canvas.drawLine(
        Offset(size.width * 0.20, size.height * 0.32),
        Offset(size.width * 0.27, size.height * 0.32),
        p0LinePaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.20, size.height * 0.39),
        Offset(size.width * 0.29, size.height * 0.39),
        p0LinePaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.20, size.height * 0.46),
        Offset(size.width * 0.25, size.height * 0.46),
        p0LinePaint,
      );
    }

    // Slide 1 Motif: UPI Digital Radar Reticle & Target Crosshairs
    if (w1 > 0.02) {
      final radarPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.34 * w1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(glowCenter, 52, radarPaint);
      canvas.drawCircle(glowCenter, 96, radarPaint);

      final crossPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.42 * w1)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round;
      // Reticle Crosshairs
      canvas.drawLine(
        Offset(glowCenter.dx - 22, glowCenter.dy),
        Offset(glowCenter.dx - 10, glowCenter.dy),
        crossPaint,
      );
      canvas.drawLine(
        Offset(glowCenter.dx + 10, glowCenter.dy),
        Offset(glowCenter.dx + 22, glowCenter.dy),
        crossPaint,
      );
      canvas.drawLine(
        Offset(glowCenter.dx, glowCenter.dy - 22),
        Offset(glowCenter.dx, glowCenter.dy - 10),
        crossPaint,
      );
      canvas.drawLine(
        Offset(glowCenter.dx, glowCenter.dy + 10),
        Offset(glowCenter.dx, glowCenter.dy + 22),
        crossPaint,
      );
    }

    // Slide 2 Motif: Offline Engine Constellation Nodes & Mesh Links
    if (w2 > 0.02) {
      final nodeCore = Paint()
        ..color = Colors.white.withValues(alpha: 0.65 * w2);
      final nodeAura = Paint()
        ..color = Colors.white.withValues(alpha: 0.22 * w2);
      final linkPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.34 * w2)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round;

      final n1 = Offset(size.width * 0.17, size.height * 0.25);
      final n2 = Offset(size.width * 0.30, size.height * 0.18);
      final n3 = Offset(size.width * 0.70, size.height * 0.19);
      final n4 = Offset(size.width * 0.85, size.height * 0.27);

      canvas.drawLine(n1, n2, linkPaint);
      canvas.drawLine(n3, n4, linkPaint);

      for (final n in [n1, n2, n3, n4]) {
        canvas.drawCircle(n, 6.0, nodeAura);
        canvas.drawCircle(n, 2.8, nodeCore);
      }
    }

    // 8. Floating 4-Point Micro-Sparkles with Silky Parallax
    _drawSparkle(
      canvas,
      Offset(size.width * 0.14 - parallaxShift * 0.3, size.height * 0.21),
      4.8,
      0.55,
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.86 - parallaxShift * 0.3, size.height * 0.18),
      5.2,
      0.60,
    );
    _drawSparkle(
      canvas,
      Offset(size.width * 0.48 - parallaxShift * 0.2, size.height * 0.13),
      4.0,
      0.50,
    );
  }

  /// Draws a crisp 4-point sparkle star with bright core glint
  void _drawSparkle(Canvas canvas, Offset center, double size, double alpha) {
    if (alpha <= 0.0) return;
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size);
    path.close();
    canvas.drawPath(path, paint);

    final corePaint = Paint()
      ..color = Colors.white.withValues(alpha: (alpha * 1.5).clamp(0.0, 1.0));
    canvas.drawCircle(center, size * 0.28, corePaint);
  }

  @override
  bool shouldRepaint(covariant _OnboardingRedWavePainter oldDelegate) =>
      oldDelegate.pageOffset != pageOffset;
}
