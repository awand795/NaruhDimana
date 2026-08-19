import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'core/theme.dart';
import 'core/constants.dart';
import 'core/router.dart';
import 'app.dart';
import 'features/detail/detail_screen.dart';
import 'features/detail/full_map_screen.dart';
import 'features/add_item/add_item_screen.dart';
import 'features/edit/edit_item_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/settings/manage_categories_screen.dart';
import 'features/settings/about_screen.dart';
import 'features/settings/privacy_policy_screen.dart';
import 'features/search/search_screen.dart';
import 'features/map_scan/map_scan_screen.dart';
import 'features/settings/edit_profile_screen.dart';
import 'data/models/item_model.dart';
import 'services/notification_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize timezone
  final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
  final timeZoneName = timeZoneInfo.identifier;
  tz_data.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  // Initialize notification service with navigation callback
  final notificationService = NotificationService();
  await notificationService.initialize(
    onNotificationTap: (itemId) {
      navigatorKey.currentState?.pushNamed(
        AppRoutes.detailItem,
        arguments: Item(
          id: itemId,
          name: '',
          location: '',
          category: 'lainnya',
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        ),
      );
    },
  );

  runApp(
    const ProviderScope(
      child: NaruhDimanaApp(),
    ),
  );
}

class NaruhDimanaApp extends StatelessWidget {
  const NaruhDimanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightTheme = lightDynamic != null
            ? AppTheme.lightTheme.copyWith(
                colorScheme: lightDynamic,
              )
            : AppTheme.lightTheme;
        final darkTheme = darkDynamic != null
            ? AppTheme.darkTheme.copyWith(
                colorScheme: darkDynamic,
              )
            : AppTheme.darkTheme;

        return MaterialApp(
          navigatorKey: navigatorKey,
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            DefaultMaterialLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('id', 'ID'),
          ],
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case AppRoutes.splash:
                return MaterialPageRoute(
                  builder: (_) => const _SplashScreen(),
                );
              case AppRoutes.onboarding:
                return MaterialPageRoute(
                  builder: (_) => const OnboardingScreen(),
                );
              case AppRoutes.home:
                return MaterialPageRoute(
                  builder: (_) => const AppShell(),
                );
              case AppRoutes.search:
                final categoryArg = settings.arguments as String?;
                return MaterialPageRoute(
                  builder: (_) => SearchScreen(initialCategory: categoryArg),
                );
              case AppRoutes.addItem:
                return MaterialPageRoute(
                  builder: (_) => const AddItemScreen(),
                );
              case AppRoutes.detailItem:
                final item = settings.arguments as Item;
                return MaterialPageRoute(
                  builder: (_) => DetailScreen(item: item),
                );
              case AppRoutes.editItem:
                final item = settings.arguments as Item;
                return MaterialPageRoute(
                  builder: (_) => EditItemScreen(item: item),
                );
              case AppRoutes.fullMap:
                final item = settings.arguments as Item;
                return MaterialPageRoute(
                  builder: (_) => FullMapScreen(item: item),
                );
              case AppRoutes.manageCategories:
                return MaterialPageRoute(
                  builder: (_) => const ManageCategoriesScreen(),
                );
              case AppRoutes.about:
                return MaterialPageRoute(
                  builder: (_) => const AboutScreen(),
                );
              case AppRoutes.privacyPolicy:
                return MaterialPageRoute(
                  builder: (_) => const PrivacyPolicyScreen(),
                );
              case AppRoutes.editProfile:
                return MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                );
              case AppRoutes.scan:
                return MaterialPageRoute(
                  builder: (_) => const MapScanScreen(initialTab: MapScanTab.scan),
                );
              case AppRoutes.mapOverview:
                return MaterialPageRoute(
                  builder: (_) => const MapScanScreen(initialTab: MapScanTab.map),
                );
              default:
                return MaterialPageRoute(
                  builder: (_) => const AppShell(),
                );
            }
          },
          initialRoute: AppRoutes.splash,
        );
      },
    );
  }
}

// ── Splash Screen ────────────────────────────────────────────
class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  late AnimationController _glowController;
  late Animation<double> _iconScale;
  late Animation<double> _iconFade;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    // Icon entrance animation
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    _iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _iconController,
        curve: const Interval(0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Glow pulse animation (infinite)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _glowPulse = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _iconController.forward();
    _checkOnboarding();
  }

  @override
  void dispose() {
    _iconController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _checkOnboarding() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingComplete =
        prefs.getBool(AppConstants.prefOnboardingComplete) ?? false;

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      onboardingComplete ? AppRoutes.home : AppRoutes.onboarding,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // ── Background gradient orbs ──────────────────────
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.primaryColor.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentColor.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container with gradient + glow
                FadeTransition(
                  opacity: _iconFade,
                  child: ScaleTransition(
                    scale: _iconScale,
                    child: AnimatedBuilder(
                      animation: _glowPulse,
                      builder: (context, child) {
                        return Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.primaryGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: _glowPulse.value),
                                blurRadius: 40,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                      child: const Icon(
                        Icons.inventory_2_rounded,
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // App name
                FadeTransition(
                  opacity: _iconFade,
                  child: const Text(
                    'NaruhDimana',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                FadeTransition(
                  opacity: _iconFade,
                  child: Text(
                    'Ingat semua, temukan segalanya',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.5),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Loading indicator at bottom ───────────────────
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
