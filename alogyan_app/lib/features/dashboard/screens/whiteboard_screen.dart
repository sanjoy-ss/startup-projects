import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../controllers/live_class_controller.dart';

class WhiteboardScreen extends StatelessWidget {
  const WhiteboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<LiveClassController>()
        ? Get.find<LiveClassController>()
        : Get.put(LiveClassController());

    return Scaffold(
      backgroundColor: AlogyanColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Flexible(
                        child: Text(
                          'Flutter Layouts & UI Whiteboard',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AlogyanColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AlogyanColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'FL-01',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AlogyanColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: AlogyanColors.success, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Auto-saved to Cloud',
                        style: TextStyle(fontSize: 11, color: AlogyanColors.success),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AlogyanColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2, size: 18, color: AlogyanColors.textSecondary),
            onPressed: () => Get.snackbar('Share Whiteboard', 'Board link copied for student broadcast.'),
          ),
          IconButton(
            icon: const Icon(LucideIcons.download, size: 18, color: AlogyanColors.textSecondary),
            onPressed: () => Get.snackbar('Export', 'Saving snapshot as PNG/PDF.'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Live Session Meta Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AlogyanColors.surface,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AlogyanColors.success, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text(
                      'Agartala Campus • Active Session',
                      style: TextStyle(fontSize: 11.5, color: AlogyanColors.textSecondary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AlogyanColors.dangerLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AlogyanColors.danger)),
                    ),
                    const SizedBox(width: 6),
                    Obx(() => Text(
                          '${controller.activeViewers.value}/24 viewers',
                          style: const TextStyle(fontSize: 11, color: AlogyanColors.textSecondary),
                        )),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AlogyanColors.border),

          // Landscape hint alert
          Obx(() {
            if (!controller.isLandscapeNoticeVisible.value) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AlogyanColors.surfaceMuted,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AlogyanColors.border),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.screenShare, size: 16, color: AlogyanColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Rotate device to landscape for expanded drawing canvas',
                      style: TextStyle(fontSize: 11.5, color: AlogyanColors.textPrimary),
                    ),
                  ),
                  InkWell(
                    onTap: controller.dismissLandscapeHint,
                    child: const Icon(LucideIcons.x, size: 14, color: AlogyanColors.textSecondary),
                  ),
                ],
              ),
            );
          }),

          // Toolbar Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Drawing permission toggle
                InkWell(
                  onTap: controller.toggleDrawingPermission,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AlogyanColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AlogyanColors.border),
                    ),
                    child: Obx(() => Row(
                          children: [
                            Icon(
                              controller.canDraw.value ? LucideIcons.unlock : LucideIcons.lock,
                              size: 14,
                              color: controller.canDraw.value ? AlogyanColors.success : AlogyanColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              controller.canDraw.value ? 'Drawing Mode Active' : 'View Only (Tap to draw)',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: controller.canDraw.value ? AlogyanColors.success : AlogyanColors.textPrimary,
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
                // Tool selection buttons
                Obx(() => Row(
                      children: [
                        _buildToolButton(
                          icon: LucideIcons.pencil,
                          isSelected: controller.selectedTool.value == 'pen',
                          onTap: () => controller.selectTool('pen'),
                        ),
                        const SizedBox(width: 4),
                        _buildToolButton(
                          icon: LucideIcons.type,
                          isSelected: controller.selectedTool.value == 'text',
                          onTap: () => controller.selectTool('text'),
                        ),
                        const SizedBox(width: 4),
                        _buildToolButton(
                          icon: LucideIcons.square,
                          isSelected: controller.selectedTool.value == 'rectangle',
                          onTap: () => controller.selectTool('rectangle'),
                        ),
                        const SizedBox(width: 4),
                        _buildToolButton(
                          icon: LucideIcons.eraser,
                          isSelected: controller.selectedTool.value == 'eraser',
                          onTap: () => controller.selectTool('eraser'),
                        ),
                      ],
                    )),
              ],
            ),
          ),

          // Whiteboard Interactive Canvas
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AlogyanColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomPaint(
                  painter: _WhiteboardDiagramPainter(),
                  child: Container(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? AlogyanColors.primaryLight : AlogyanColors.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AlogyanColors.primary : AlogyanColors.border),
        ),
        child: Icon(icon, size: 16, color: isSelected ? AlogyanColors.primary : AlogyanColors.textSecondary),
      ),
    );
  }
}

class _WhiteboardDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 1. Grid background dots
    final dotPaint = Paint()..color = const Color(0xFFCBD5E1);
    for (double x = 16; x < size.width; x += 24) {
      for (double y = 16; y < size.height; y += 24) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }

    // 2. Draw Flutter Architecture Scaffold box
    final strokePaint = Paint()
      ..color = const Color(0xFF475467)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final rectScaffold = RRect.fromRectAndRadius(
      Rect.fromLTWH(24, 24, size.width - 48, size.height - 48),
      const Radius.circular(8),
    );
    canvas.drawRRect(rectScaffold, strokePaint);

    // Label: Scaffold (Root Viewport)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = const TextSpan(
      text: 'Scaffold (Root Viewport)',
      style: TextStyle(color: Color(0xFF475467), fontSize: 12, fontWeight: FontWeight.w700),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(34, 32));

    // 3. AppBar Box
    final appBarFill = Paint()
      ..color = const Color(0xFFDCFCE7)
      ..style = PaintingStyle.fill;
    final appBarStroke = Paint()
      ..color = const Color(0xFF16A34A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rectAppBar = RRect.fromRectAndRadius(
      Rect.fromLTWH(36, 56, size.width - 72, 44),
      const Radius.circular(6),
    );
    canvas.drawRRect(rectAppBar, appBarFill);
    canvas.drawRRect(rectAppBar, appBarStroke);

    textPainter.text = const TextSpan(
      text: "AppBar(title: Text('My App'))",
      style: TextStyle(color: Color(0xFF16A34A), fontSize: 11, fontWeight: FontWeight.w600),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(46, 70));

    // 4. Column Content Box
    final columnStroke = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rectColumn = RRect.fromRectAndRadius(
      Rect.fromLTWH(36, 116, size.width - 72, size.height - 180),
      const Radius.circular(6),
    );
    canvas.drawRRect(rectColumn, columnStroke);

    textPainter.text = const TextSpan(
      text: 'Column(children: [...])',
      style: TextStyle(color: Color(0xFF0F172A), fontSize: 11, fontWeight: FontWeight.w700),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(46, 128));

    // Sub-widgets inside Column
    final childStroke = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Row 1: Header Row
    final rectRow1 = RRect.fromRectAndRadius(
      Rect.fromLTWH(48, 156, size.width - 96, 36),
      const Radius.circular(4),
    );
    canvas.drawRRect(rectRow1, childStroke);
    textPainter.text = const TextSpan(
      text: 'Row(children: [Text, Icon])',
      style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w500),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(56, 168));

    // Row 2: Expanded View
    final rectRow2 = RRect.fromRectAndRadius(
      Rect.fromLTWH(48, 204, size.width - 96, 60),
      const Radius.circular(4),
    );
    final fillRow2 = Paint()..color = const Color(0xFFF1F5F9);
    canvas.drawRRect(rectRow2, fillRow2);
    canvas.drawRRect(rectRow2, childStroke);
    textPainter.text = const TextSpan(
      text: 'Expanded(child: ListView.builder(...))',
      style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.w600),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(56, 226));

    // Teacher's red annotation
    final redPaint = Paint()
      ..color = const Color(0xFFD32F2F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(size.width - 120, 174),
      Offset(size.width - 60, 150),
      redPaint,
    );
    textPainter.text = const TextSpan(
      text: '← crossAxisAlignment: center',
      style: TextStyle(color: Color(0xFFD32F2F), fontSize: 9.5, fontWeight: FontWeight.w600),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 200, 134));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
