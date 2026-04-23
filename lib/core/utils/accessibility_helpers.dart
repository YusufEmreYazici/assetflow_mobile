import 'package:flutter/material.dart';

class A11y {
  A11y._();

  /// Icon-only butonlar için semantic wrapper
  static Widget iconButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    double size = 24,
    Color? color,
  }) {
    return Semantics(
      label: label,
      button: true,
      excludeSemantics: true,
      child: IconButton(
        icon: Icon(icon, size: size, color: color),
        onPressed: onPressed,
        tooltip: label,
      ),
    );
  }

  /// Status chip'ler için semantic wrapper
  static Widget statusChip({
    required String statusText,
    required Widget child,
  }) {
    return Semantics(
      label: 'Durum: $statusText',
      child: ExcludeSemantics(child: child),
    );
  }

  /// Okunabilir sayaç semantic'i (ör. "158 cihaz")
  static Widget counter({
    required String value,
    required String unitLabel,
    required Widget child,
  }) {
    return Semantics(
      label: '$value $unitLabel',
      child: ExcludeSemantics(child: child),
    );
  }
}
