import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/home/home_screen.dart';
import 'features/search/search_screen.dart';
import 'features/settings/profile_screen.dart';
import 'core/theme.dart';
import 'core/router.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: AppTheme.mediumDuration,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.15, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_currentIndex),
              child: _screens[_currentIndex],
            ),
          ),

          // ── Floating dock ──────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: SafeArea(
              top: false,
              child: Center(
                child: _FloatingDock(
                  currentIndex: _currentIndex,
                  onSelect: (index) {
                    HapticFeedback.lightImpact();
                    setState(() => _currentIndex = index);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating dock pill glass ala desain Stitch:
/// 5 slot — Beranda, Cari, [FAB +], Peta, Profil.
class _FloatingDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onSelect;

  const _FloatingDock({required this.currentIndex, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 62,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _DockItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                label: 'Beranda',
                selected: currentIndex == 0,
                onTap: () => onSelect(0),
              ),
              _DockItem(
                icon: Icons.search_outlined,
                selectedIcon: Icons.search_rounded,
                label: 'Cari',
                selected: currentIndex == 1,
                onTap: () => onSelect(1),
              ),
              _DockFab(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pushNamed(context, AppRoutes.addItem);
                },
              ),
              _DockItem(
                icon: Icons.map_outlined,
                selectedIcon: Icons.map_rounded,
                label: 'Peta',
                selected: false,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pushNamed(context, AppRoutes.mapOverview);
                },
              ),
              _DockItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person_rounded,
                label: 'Profil',
                selected: currentIndex == 2,
                onTap: () => onSelect(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DockItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppTheme.primaryColor : AppTheme.textSecondary;

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(selected ? selectedIcon : icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DockFab extends StatelessWidget {
  final VoidCallback onTap;

  const _DockFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.translate(
        offset: const Offset(0, -8),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: AppTheme.elevatedShadow(alpha: 0.3),
          ),
          child: const Icon(Icons.add_rounded, size: 26, color: Colors.white),
        ),
      ),
    );
  }
}
