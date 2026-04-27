import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:assetflow_mobile/core/theme/app_theme.dart';

class AnimatedLogoLoading extends StatefulWidget {
  final Color backgroundColor;
  final double logoSize;
  final String? message;

  const AnimatedLogoLoading({
    super.key,
    this.backgroundColor = AppColors.navy,
    this.logoSize = 64,
    this.message,
  });

  @override
  State<AnimatedLogoLoading> createState() => _AnimatedLogoLoadingState();
}

class _AnimatedLogoLoadingState extends State<AnimatedLogoLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _fadeAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _scaleAnim = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (_, child) => FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(scale: _scaleAnim, child: child),
              ),
              child: SvgPicture.asset(
                'assets/animated/logo-mark-animated.svg',
                width: widget.logoSize,
                height: widget.logoSize,
              ),
            ),
            if (widget.message != null) ...[
              const SizedBox(height: 20),
              Text(
                widget.message!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
