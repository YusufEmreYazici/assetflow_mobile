import 'package:flutter/material.dart';

/// İlk yüklemede liste item'larının kademeli kayarak gelmesini sağlar.
/// Performans için sadece ilk 10 item'a uygulanır.
class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;
  final Duration? delay;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
    this.delay,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _offset = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    final delay = widget.delay ?? Duration(milliseconds: widget.index * 45);
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
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
      builder: (context, child) => FadeTransition(
        opacity: _opacity,
        child: SlideTransition(position: _offset, child: child),
      ),
      child: widget.child,
    );
  }
}
