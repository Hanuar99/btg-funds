import 'package:btg_funds_manager/core/theme/tokens/app_animations.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_typography.dart';
import 'package:btg_funds_manager/core/utils/responsive_layout.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:flutter/material.dart';

class CategoryFilter extends StatefulWidget {
  const CategoryFilter({
    required this.funds,
    required this.onFilterChanged,
    this.initialCategory,
    super.key,
  });

  final List<Fund> funds;
  final void Function(FundCategory? category) onFilterChanged;
  final FundCategory? initialCategory;

  @override
  State<CategoryFilter> createState() => _CategoryFilterState();
}

class _CategoryFilterState extends State<CategoryFilter> {
  FundCategory? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialCategory;
  }

  @override
  void didUpdateWidget(covariant CategoryFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCategory != widget.initialCategory) {
      _selected = widget.initialCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = widget.funds.length;
    final fpvCount = widget.funds
        .where((fund) => fund.category == FundCategory.fpv)
        .length;
    final ficCount = widget.funds
        .where((fund) => fund.category == FundCategory.fic)
        .length;

    final items = [
      _CategoryItem(label: 'Todos', count: totalCount, category: null),
      _CategoryItem(label: 'FPV', count: fpvCount, category: FundCategory.fpv),
      _CategoryItem(label: 'FIC', count: ficCount, category: FundCategory.fic),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth >= Breakpoints.tablet;
        final canFitInline = constraints.maxWidth >= 420;

        if (isWeb) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: items
                  .map(
                    (item) => ConstrainedBox(
                      constraints: const BoxConstraints(
                        minWidth: 168,
                        maxWidth: 220,
                      ),
                      child: _CategoryPill(
                        item: item,
                        selected: _selected == item.category,
                        isWeb: true,
                        onTap: () => _handleSelection(item.category),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          );
        }

        if (canFitInline) {
          return Row(
            children: items
                .map(
                  (item) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: item == items.last ? 0 : AppSpacing.xs,
                      ),
                      child: _CategoryPill(
                        item: item,
                        selected: _selected == item.category,
                        isWeb: false,
                        onTap: () => _handleSelection(item.category),
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
            child: Row(
              children: items
                  .map(
                    (item) => Padding(
                      padding: EdgeInsets.only(
                        right: item == items.last ? 0 : AppSpacing.xs,
                      ),
                      child: _CategoryPill(
                        item: item,
                        selected: _selected == item.category,
                        isWeb: false,
                        onTap: () => _handleSelection(item.category),
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
        );
      },
    );
  }

  void _handleSelection(FundCategory? category) {
    if (_selected == category) {
      return;
    }

    setState(() {
      _selected = category;
    });
    widget.onFilterChanged(category);
  }
}

class _CategoryPill extends StatefulWidget {
  const _CategoryPill({
    required this.item,
    required this.selected,
    required this.isWeb,
    required this.onTap,
  });

  final _CategoryItem item;
  final bool selected;
  final bool isWeb;
  final VoidCallback onTap;

  @override
  State<_CategoryPill> createState() => _CategoryPillState();
}

class _CategoryPillState extends State<_CategoryPill> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.selected || _isHovered;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: AppRadius.fullRadius,
          child: AnimatedContainer(
            duration: AppAnimations.normal,
            curve: AppAnimations.defaultCurve,
            width: widget.isWeb ? double.infinity : null,
            padding: EdgeInsets.symmetric(
              horizontal: widget.isWeb ? AppSpacing.lg : AppSpacing.md,
              vertical: widget.isWeb ? AppSpacing.md : AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: widget.selected
                  ? AppColors.primary
                  : AppColors.backgroundSecondary,
              borderRadius: AppRadius.fullRadius,
              border: Border.all(
                color: widget.selected
                    ? Colors.transparent
                    : isHighlighted
                    ? AppColors.primarySoft
                    : AppColors.border,
              ),
              boxShadow: widget.selected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.16),
                        blurRadius: widget.isWeb
                            ? AppSpacing.lg
                            : AppSpacing.md,
                        offset: const Offset(0, AppSpacing.xxs),
                      ),
                    ]
                  : isHighlighted
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: AppSpacing.sm,
                        offset: const Offset(0, AppSpacing.xxs),
                      ),
                    ]
                  : const [],
            ),
            child: Row(
              mainAxisSize: widget.isWeb ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (widget.isWeb)
                  Expanded(
                    child: Text(
                      widget.item.label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.labelLarge.copyWith(
                        color: widget.selected
                            ? AppColors.textOnPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  )
                else
                  Text(
                    widget.item.label,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelLarge.copyWith(
                      color: widget.selected
                          ? AppColors.textOnPrimary
                          : AppColors.textPrimary,
                    ),
                  ),
                const SizedBox(width: AppSpacing.xs),
                AnimatedContainer(
                  duration: AppAnimations.normal,
                  curve: AppAnimations.defaultCurve,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: widget.selected
                        ? AppColors.textOnPrimary.withValues(alpha: 0.16)
                        : isHighlighted
                        ? AppColors.primaryLight
                        : AppColors.backgroundCard,
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Text(
                    '${widget.item.count}',
                    style: AppTypography.labelSmall.copyWith(
                      color: widget.selected
                          ? AppColors.textOnPrimary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.label,
    required this.count,
    required this.category,
  });

  final String label;
  final int count;
  final FundCategory? category;
}
