import 'dart:async';

import 'package:btg_funds_manager/core/theme/tokens/app_animations.dart';
import 'package:flutter/material.dart';

class AnimatedFundItem extends StatefulWidget {
  const AnimatedFundItem({
    required this.index,
    required this.child,
    super.key,
  });

  final int index;
  final Widget child;

  @override
  State<AnimatedFundItem> createState() => _AnimatedFundItemState();
}

class _AnimatedFundItemState extends State<AnimatedFundItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.normal,
    );
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.enterCurve,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(curvedAnimation);

    Future<void>.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) {
        unawaited(_controller.forward());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}
