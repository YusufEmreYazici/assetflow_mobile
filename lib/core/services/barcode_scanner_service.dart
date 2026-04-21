import 'package:flutter/material.dart';
import 'package:assetflow_mobile/features/scanner/scanner_screen.dart';

class BarcodeScannerService {
  static Future<String?> scanBarcode(BuildContext context) {
    return Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScannerScreen()),
    );
  }

  /// GVN-LPT-0142, ZMT-20260421-0142 gibi demirbaş kodlarını tanır.
  static bool isAssetCode(String code) {
    return RegExp(r'^(GVN|ZMT)-').hasMatch(code);
  }
}
