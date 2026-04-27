import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

/// Full-screen QR/barcode scanner.
/// Returns the scanned string via Navigator.pop, or null if cancelled.
class QrScannerScreen extends StatefulWidget {
  final String title;
  final String hint;

  const QrScannerScreen({
    super.key,
    this.title = 'QR / Barkod Tara',
    this.hint = 'Kamerayı koda doğrultun',
  });

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;
    _scanned = true;
    Navigator.of(context).pop(barcode!.rawValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(widget.title),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Overlay
          CustomPaint(
            painter: _ScannerOverlayPainter(),
            child: const SizedBox.expand(),
          ),
          // Hint text
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.hint,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Draws a semi-transparent overlay with a clear scan window in the center.
class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const windowSize = 240.0;
    final left = (size.width - windowSize) / 2;
    final top = (size.height - windowSize) / 2;
    final window = Rect.fromLTWH(left, top, windowSize, windowSize);

    final paint = Paint()..color = Colors.black.withValues(alpha: 0.55);

    // Draw 4 dark regions around the scan window
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, window.top), paint);
    canvas.drawRect(
      Rect.fromLTWH(0, window.bottom, size.width, size.height - window.bottom),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, window.top, window.left, windowSize),
      paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        window.right,
        window.top,
        size.width - window.right,
        windowSize,
      ),
      paint,
    );

    // Corner brackets
    const cornerLen = 28.0;
    const cornerWidth = 4.0;
    final cornerPaint = Paint()
      ..color = AppColors.primary400
      ..strokeWidth = cornerWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(
      Offset(window.left, window.top + cornerLen),
      Offset(window.left, window.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(window.left, window.top),
      Offset(window.left + cornerLen, window.top),
      cornerPaint,
    );
    // Top-right
    canvas.drawLine(
      Offset(window.right - cornerLen, window.top),
      Offset(window.right, window.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(window.right, window.top),
      Offset(window.right, window.top + cornerLen),
      cornerPaint,
    );
    // Bottom-left
    canvas.drawLine(
      Offset(window.left, window.bottom - cornerLen),
      Offset(window.left, window.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(window.left, window.bottom),
      Offset(window.left + cornerLen, window.bottom),
      cornerPaint,
    );
    // Bottom-right
    canvas.drawLine(
      Offset(window.right - cornerLen, window.bottom),
      Offset(window.right, window.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(window.right, window.bottom),
      Offset(window.right, window.bottom - cornerLen),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
