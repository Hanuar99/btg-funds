import 'dart:async';

import 'package:btg_funds_manager/core/theme/tokens/app_animations.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

class FundCardSkeleton extends StatefulWidget {
  const FundCardSkeleton({super.key});

  @override
  State<FundCardSkeleton> createState() => _FundCardSkeletonState();
}

class _FundCardSkeletonState extends State<FundCardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.shimmer,
    );
    unawaited(_controller.repeat(reverse: true));
    _opacity = Tween<double>(begin: 0.3, end: 0.9).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: AppColors.border,
        ),
        color: AppColors.backgroundCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildShimmerRect(width: 48, height: 22),
              const Spacer(),
              _buildShimmerRect(width: 60, height: 22),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildShimmerRect(width: 220, height: 16),
          const SizedBox(height: AppSpacing.xs),
          _buildShimmerRect(width: 140, height: 12),
          const SizedBox(height: AppSpacing.md),
          _buildShimmerRect(width: double.infinity, height: 44),
        ],
      ),
    );
  }

  Widget _buildShimmerRect({required double width, required double height}) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.border.withValues(alpha: _opacity.value),
            borderRadius: AppRadius.smRadius,
          ),
        );
      },
    );
  }
}

class FundListSkeleton extends StatelessWidget {
  const FundListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (_, _) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: FundCardSkeleton(),
          ),
          childCount: 5,
        ),
      ),
    );
  }
}
