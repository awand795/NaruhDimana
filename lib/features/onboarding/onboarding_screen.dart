import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme.dart';
import '../../core/constants.dart';
import '../../core/router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.inventory_2_rounded,
      title: 'Simpan Barangmu',
      description:
          'Catat semua barang berhargamu beserta lokasi penyimpanannya. Tidak ada lagi barang hilang!',
      iconBg: AppTheme.secondaryFixed,
      iconColor: AppTheme.onSecondaryFixedVariant,
    ),
    _OnboardingPage(
      icon: Icons.location_on_rounded,
      title: 'Lacak dengan GPS',
      description:
          'Simpan lokasi GPS setiap barang. Buka peta dan langsung tahu di mana barangmu disimpan.',
      iconBg: AppTheme.primaryFixed,
      iconColor: AppTheme.onPrimaryFixedVariant,
    ),
    _OnboardingPage(
      icon: Icons.notifications_active_rounded,
      title: 'Dapatkan Pengingat',
      description:
          'Atur pengingat untuk barang-barang penting. Tidak akan lupa lagi di mana menyimpannya!',
      iconBg: AppTheme.tertiaryFixed,
      iconColor: AppTheme.accentColor,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefOnboardingComplete, true);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // ── Background gradient orbs ─────────────────────
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main content ─────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // ── Top row: skip ────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _completeOnboarding,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusPill),
                          ),
                          child: const Text(
                            'Lewati',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Page view ────────────────────────────────
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final page = _pages[index];
                      return Padding(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Icon container with glow
                            Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                color: page.iconBg,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: page.iconColor
                                        .withValues(alpha: 0.3),
                                    blurRadius: 40,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                page.icon,
                                size: 64,
                                color: page.iconColor,
                              ),
                            )
                                .animate()
                                .scale(
                                  duration: 500.ms,
                                  curve: Curves.elasticOut,
                                  begin: const Offset(0.85, 0.85),
                                )
                                .fadeIn(duration: 300.ms),
                            const SizedBox(height: 48),

                            // Title
                            Text(
                              page.title,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(
                                  duration: 400.ms,
                                  delay: 150.ms,
                                  curve: Curves.easeOut,
                                )
                                .slideY(begin: 0.08),
                            const SizedBox(height: 16),

                            // Description
                            Text(
                              page.description,
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    Colors.white.withValues(alpha: 0.65),
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            )
                                .animate()
                                .fadeIn(
                                  duration: 400.ms,
                                  delay: 250.ms,
                                  curve: Curves.easeOut,
                                )
                                .slideY(begin: 0.08),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // ── Bottom section ───────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 0, 40, 48),
                  child: Column(
                    children: [
                      // Dot indicators — pill style
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 32 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppTheme.primaryColor
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Next / Mulai button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == _pages.length - 1) {
                              _completeOnboarding();
                            } else {
                              _pageController.nextPage(
                                duration:
                                    const Duration(milliseconds: 350),
                                curve: Curves.easeInOutCubic,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor:
                                AppTheme.primaryColor.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusM),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _pages.length - 1
                                    ? 'Mulai'
                                    : 'Selanjutnya',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage == _pages.length - 1
                                    ? Icons.arrow_forward_rounded
                                    : Icons.arrow_forward_ios_rounded,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Brand footer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_rounded,
                            size: 16,
                            color:
                                Colors.white.withValues(alpha: 0.3),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'NaruhDimana',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color:
                                  Colors.white.withValues(alpha: 0.3),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
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

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color iconBg;
  final Color iconColor;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconBg,
    required this.iconColor,
  });
}
