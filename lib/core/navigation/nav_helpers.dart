import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Back handler: pops if possible, else navigates to home shell.
VoidCallback goBackOrHome(BuildContext context) {
  return () {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      context.go('/');
    }
  };
}
