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

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      icon: Icons.inventory_2,
      title: 'Simpan Barangmu',
      description:
          'Catat semua barang berhargamu beserta lokasi penyimpanannya. Tidak ada lagi barang hilang!',
      color: AppTheme.primaryColor,
    ),
    _OnboardingPage(
      icon: Icons.location_on,
      title: 'Lacak dengan GPS',
      description:
          'Simpan lokasi GPS setiap barang. Buka peta dan langsung tahu di mana barangmu disimpan.',
      color: Colors.green,
    ),
    _OnboardingPage(
      icon: Icons.notifications_active,
      title: 'Dapatkan Pengingat',
      description:
          'Atur pengingat untuk barang-barang penting. Tidak akan lupa lagi di mana menyimpannya!',
      color: AppTheme.secondaryColor,
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
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: const Text('Lewati'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: page.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(70),
                          ),
                          child: Icon(
                            page.icon,
                            size: 70,
                            color: page.color,
                          ),
                        ).animate().scale(
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                          begin: const Offset(0, 0),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(
                          duration: 500.ms,
                          delay: 200.ms,
                          curve: Curves.easeOut,
                        ).slideY(begin: 0.1),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                color: AppTheme.textSecondary,
                                height: 1.5,
                              ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(
                          duration: 500.ms,
                          delay: 350.ms,
                          curve: Curves.easeOut,
                        ).slideY(begin: 0.1),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppTheme.primaryColor
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Next/Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Mulai'
                        : 'Selanjutnya',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
