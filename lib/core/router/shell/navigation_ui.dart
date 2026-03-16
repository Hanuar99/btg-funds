import 'package:btg_funds_manager/core/theme/tokens/app_animations.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_typography.dart';
import 'package:btg_funds_manager/features/funds/presentation/widgets/balance_header.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void goToBranch(StatefulNavigationShell navigationShell, int index) {
  navigationShell.goBranch(
    index,
    initialLocation: index == navigationShell.currentIndex,
  );
}

class BtgSidebar extends StatelessWidget {
  const BtgSidebar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(
          right: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppRadius.mdRadius,
                    ),
                    child: const Icon(
                      Icons.account_balance,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.grid),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BTG Fondos', style: AppTypography.titleMedium),
                        Text(
                          'Gestión de inversiones',
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: BalanceHeader(compact: true),
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.sm),
            SidebarNavItem(
              icon: Icons.account_balance_outlined,
              activeIcon: Icons.account_balance,
              label: 'Fondos',
              isActive: navigationShell.currentIndex == 0,
              onTap: () => goToBranch(navigationShell, 0),
            ),
            SidebarNavItem(
              icon: Icons.receipt_long_outlined,
              activeIcon: Icons.receipt_long,
              label: 'Historial',
              isActive: navigationShell.currentIndex == 1,
              onTap: () => goToBranch(navigationShell, 1),
            ),
            const Spacer(),
            const Divider(height: 1),
            const _SidebarFooter(),
          ],
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: AppRadius.smRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.support_agent_outlined,
              size: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BTG Fondos',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  'v1.0.0 · Prueba técnica',
                  style: AppTypography.labelXSmall.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarNavItem extends StatefulWidget {
  const SidebarNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.grid,
        vertical: AppSpacing.micro,
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: AppAnimations.fast,
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primaryLight
                : _isHovered
                ? AppColors.backgroundSecondary
                : Colors.transparent,
            borderRadius: AppRadius.mdRadius,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: AppRadius.mdRadius,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: AppRadius.mdRadius,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.grid,
                  vertical: AppSpacing.sm + AppSpacing.micro,
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isActive ? widget.activeIcon : widget.icon,
                      color: widget.isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.grid),
                    Text(
                      widget.label,
                      style:
                          (widget.isActive
                                  ? AppTypography.labelLarge
                                  : AppTypography.bodyMedium)
                              .copyWith(
                                color: widget.isActive
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TabSwitcher extends StatefulWidget {
  const TabSwitcher({
    required this.selectedIndex,
    required this.children,
    super.key,
  });

  final int selectedIndex;
  final List<Widget> children;

  @override
  State<TabSwitcher> createState() => _TabSwitcherState();
}

class _TabSwitcherState extends State<TabSwitcher> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant TabSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != _currentIndex) {
      setState(() {
        _currentIndex = widget.selectedIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: List<Widget>.generate(widget.children.length, (index) {
        final isActive = index == _currentIndex;
        return IgnorePointer(
          ignoring: !isActive,
          child: AnimatedOpacity(
            opacity: isActive ? 1 : 0,
            duration: AppAnimations.fast,
            curve: isActive
                ? AppAnimations.enterCurve
                : AppAnimations.exitCurve,
            child: TickerMode(
              enabled: isActive,
              child: KeyedSubtree(
                key: ValueKey<int>(index),
                child: widget.children[index],
              ),
            ),
          ),
        );
      }),
    );
  }
}
