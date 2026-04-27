import 'package:flutter/material.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class ScanOverlay extends StatefulWidget {
  const ScanOverlay({super.key});

  @override
  State<ScanOverlay> createState() => _ScanOverlayState();
}

class _ScanOverlayState extends State<ScanOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ScanOverlayPainter(scanProgress: _controller.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  final double scanProgress;
  static const _windowSize = 250.0;
  static const _cornerLen = 30.0;

  const _ScanOverlayPainter({required this.scanProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final left = (size.width - _windowSize) / 2;
    final top = (size.height - _windowSize) / 2;
    final window = Rect.fromLTWH(left, top, _windowSize, _windowSize);

    // Dark overlay around scan window
    final darkPaint = Paint()..color = Colors.black.withValues(alpha: 0.60);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, window.top), darkPaint);
    canvas.drawRect(
      Rect.fromLTWH(0, window.bottom, size.width, size.height - window.bottom),
      darkPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, window.top, window.left, _windowSize),
      darkPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        window.right,
        window.top,
        size.width - window.right,
        _windowSize,
      ),
      darkPaint,
    );

    // Corner brackets
    final cornerPaint = Paint()
      ..color = AppColors.primary400
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(
      Offset(window.left, window.top + _cornerLen),
      Offset(window.left, window.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(window.left, window.top),
      Offset(window.left + _cornerLen, window.top),
      cornerPaint,
    );
    // Top-right
    canvas.drawLine(
      Offset(window.right - _cornerLen, window.top),
      Offset(window.right, window.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(window.right, window.top),
      Offset(window.right, window.top + _cornerLen),
      cornerPaint,
    );
    // Bottom-left
    canvas.drawLine(
      Offset(window.left, window.bottom - _cornerLen),
      Offset(window.left, window.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(window.left, window.bottom),
      Offset(window.left + _cornerLen, window.bottom),
      cornerPaint,
    );
    // Bottom-right
    canvas.drawLine(
      Offset(window.right - _cornerLen, window.bottom),
      Offset(window.right, window.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(window.right, window.bottom),
      Offset(window.right, window.bottom - _cornerLen),
      cornerPaint,
    );

    // Animated scan line with gradient fade at edges
    final scanY = window.top + scanProgress * _windowSize;
    final scanShader = LinearGradient(
      colors: [
        AppColors.primary400.withValues(alpha: 0.0),
        AppColors.primary400.withValues(alpha: 0.9),
        AppColors.primary400.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromLTWH(window.left, scanY - 1, _windowSize, 2));

    final scanPaint = Paint()
      ..shader = scanShader
      ..strokeWidth = 2.5;
    canvas.drawLine(
      Offset(window.left, scanY),
      Offset(window.right, scanY),
      scanPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter old) =>
      old.scanProgress != scanProgress;
}
