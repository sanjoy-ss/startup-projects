import 'dart:math' as math;
import 'package:flutter/material.dart';
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
        alignment: _SlideAlignment.rightMascot,
        stepNumber: '01',
        totalSteps: '03',
        category: 'ATTENDANCE',
        techBadge: 'Smart 1-Tap Roster',
        title: 'Attendance in\nten seconds flat.',
        description:
            'Mark your entire batch in one tap, toggle absentees with ease, and dispatch WhatsApp alerts to parents instantly.',
        mascotBytes: OnboardingMascotData.attendanceBytes,
        accentColor: AlogyanColors.success,
      ),
      _OnboardingSlideData(
        index: 1,
        alignment: _SlideAlignment.leftMascot,
        stepNumber: '02',
        totalSteps: '03',
        category: 'SMART PAYMENTS',
        techBadge: 'Dynamic BHIM UPI',
        title: 'Tuition fees paid\nvia dynamic UPI.',
        description:
            'Display student-specific UPI QR codes directly on your screen. No card machines, zero delays, and instant receipts.',
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
        description:
            'Basements and weak signals will never stop class. Everything queues safely on your phone and syncs when reconnected.',
        mascotBytes: OnboardingMascotData.offlineBytes,
        accentColor: const Color(0xFF2563EB),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Dynamic Tech Background with Continuity to Login Screen
          Positioned.fill(
            child: Obx(() {
              return CustomPaint(
                painter: _DynamicEvolvingBackgroundPainter(
                  pageIndex: controller.currentPage.value,
                ),
              );
            }),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top App Bar with Alogyan emblem and discrete Skip
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Alogyan Brand Mark
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AlogyanColors.primary, AlogyanColors.primaryDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(11),
                              boxShadow: [
                                BoxShadow(
                                  color: AlogyanColors.primary.withValues(alpha: 0.25),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                LucideIcons.graduationCap,
                                color: Colors.white,
                                size: 19,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
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
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                      color: AlogyanColors.textPrimary,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  Text(
                                    '.',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w900,
                                      color: AlogyanColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const Text(
                                'Educator Companion',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AlogyanColors.textMuted,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Minimalist Skip action
                      Obx(() {
                        final isLast = controller.currentPage.value == OnboardingController.totalPages - 1;
                        if (isLast) {
                          return const SizedBox(width: 48, height: 32);
                        }
                        return InkWell(
                          onTap: controller.finishOnboarding,
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            child: Text(
                              'Skip',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AlogyanColors.textSecondary,
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
                            final isActive = controller.currentPage.value == index;
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
                        final isLast = controller.currentPage.value == slides.length - 1;
                        return ElevatedButton(
                          onPressed: controller.nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AlogyanColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shadowColor: AlogyanColors.primary.withValues(alpha: 0.35),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
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
                                isLast ? LucideIcons.arrowRight : LucideIcons.chevronRight,
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
    );
  }
}

enum _SlideAlignment {
  rightMascot,  // Slide 1: Mascot Right, Text Left
  leftMascot,   // Slide 2: Mascot Left, Text Right
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
    final size = MediaQuery.of(context).size;
    final heroHeight = math.min(size.height * 0.38, 300.0);
    final mascotSize = math.min(heroHeight * 0.88, 250.0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: data.alignment == _SlideAlignment.centerMascot
            ? CrossAxisAlignment.center
            : (data.alignment == _SlideAlignment.leftMascot ? CrossAxisAlignment.end : CrossAxisAlignment.start),
        children: [
          SizedBox(height: size.height * 0.01),

          // Dynamic Hero Stage positioned according to Slide Spatial Identity
          SizedBox(
            height: heroHeight,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 1. Dynamic Free-Standing Action Mascot (No container box, no card, no border)
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
                      child: _buildFreestandingMascot(mascotSize, data),
                    ),
                  ),

                // 2. Interactive Floating Tech Status Badge
                if (data.alignment == _SlideAlignment.rightMascot)
                  Positioned(
                    left: 0,
                    bottom: heroHeight * 0.12,
                    child: _buildTechBadge(data),
                  )
                else if (data.alignment == _SlideAlignment.leftMascot)
                  Positioned(
                    right: 0,
                    bottom: heroHeight * 0.12,
                    child: _buildTechBadge(data),
                  )
                else
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _buildTechBadge(data),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: size.height * 0.02),

          // Clean Editorial Step Marker
          if (data.alignment == _SlideAlignment.centerMascot)
            Row(
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
            )
          else if (data.alignment == _SlideAlignment.leftMascot)
            Row(
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
            )
          else
            Row(
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
            ),

          const SizedBox(height: 14),

          // Editorial Headline (Respects Alignment)
          Text(
            data.title,
            textAlign: data.alignment == _SlideAlignment.centerMascot
                ? TextAlign.center
                : (data.alignment == _SlideAlignment.leftMascot ? TextAlign.right : TextAlign.left),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: AlogyanColors.textPrimary,
              height: 1.18,
              letterSpacing: -0.7,
            ),
          ),

          const SizedBox(height: 14),

          // Clear Subtitle (Respects Alignment)
          Text(
            data.description,
            textAlign: data.alignment == _SlideAlignment.centerMascot
                ? TextAlign.center
                : (data.alignment == _SlideAlignment.leftMascot ? TextAlign.right : TextAlign.left),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AlogyanColors.textSecondary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreestandingMascot(double mascotSize, _OnboardingSlideData data) {
    return SizedBox(
      width: mascotSize,
      height: mascotSize,
      child: Image.memory(
        data.mascotBytes,
        fit: BoxFit.contain,
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

/// Dynamic Evolving Background Painter: Shifts gracefully across slides for continuous narrative
class _DynamicEvolvingBackgroundPainter extends CustomPainter {
  final int pageIndex;

  _DynamicEvolvingBackgroundPainter({required this.pageIndex});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Shift Primary Warm Glow based on Slide Journey
    final glowCenter = pageIndex == 1
        ? Offset(size.width * 0.12, size.height * 0.14) // Slide 2: Left Glow
        : (pageIndex == 2
            ? Offset(size.width * 0.50, size.height * 0.12) // Slide 3: Center Grounding Glow
            : Offset(size.width * 0.88, size.height * 0.12)); // Slide 1: Right Glow

    final glowColor = pageIndex == 1
        ? AlogyanColors.warning.withValues(alpha: 0.07)
        : (pageIndex == 2
            ? const Color(0xFF2563EB).withValues(alpha: 0.07)
            : AlogyanColors.primary.withValues(alpha: 0.08));

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor,
          glowColor.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: glowCenter,
          radius: size.width * 0.65,
        ),
      );
    canvas.drawCircle(glowCenter, size.width * 0.65, glowPaint);

    // 2. Secondary Tech Glow (Opposing Corner for Balance)
    final secondaryCenter = pageIndex == 1
        ? Offset(size.width * 0.88, size.height * 0.82)
        : Offset(size.width * 0.10, size.height * 0.85);

    final secondaryPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF2563EB).withValues(alpha: 0.05),
          const Color(0xFF2563EB).withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromCircle(
          center: secondaryCenter,
          radius: size.width * 0.55,
        ),
      );
    canvas.drawCircle(secondaryCenter, size.width * 0.55, secondaryPaint);

    // 3. Dynamic Narrative Orbital Arc (Continuity with Login Screen)
    final arcPaint = Paint()
      ..color = AlogyanColors.primary.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final arcCenter = pageIndex == 1
        ? Offset(size.width * 0.08, size.height * 0.16)
        : (pageIndex == 2
            ? Offset(size.width * 0.50, size.height * 0.14)
            : Offset(size.width * 0.92, size.height * 0.16));

    canvas.drawArc(
      Rect.fromCircle(
        center: arcCenter,
        radius: 130,
      ),
      0,
      math.pi * 2,
      false,
      arcPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(
        center: arcCenter,
        radius: 180,
      ),
      math.pi * 0.3,
      math.pi * 0.7,
      false,
      arcPaint..strokeWidth = 0.8,
    );

    // 4. Subtle Decorative Orbit Arc (Bottom)
    final bottomArcPaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width * 0.05, size.height * 0.92),
        radius: 140,
      ),
      -math.pi * 0.4,
      math.pi * 0.9,
      false,
      bottomArcPaint,
    );

    // 5. Delicate Floating Geometric Sparkles
    final dotPaint = Paint()..color = AlogyanColors.primary.withValues(alpha: 0.14);
    canvas.drawCircle(Offset(size.width * 0.15, size.height * 0.18), 2.5, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.38), 3.0, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.08, size.height * 0.65), 2.0, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.78), 2.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _DynamicEvolvingBackgroundPainter oldDelegate) =>
      oldDelegate.pageIndex != pageIndex;
}
