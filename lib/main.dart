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
      statusBarIconBrightness: Brightness.dark,
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

class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.elasticOut,
      ),
    );
    _animController.forward();
    _checkOnboarding();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkOnboarding() async {
    await Future.delayed(const Duration(milliseconds: 2000));
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
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inventory_2,
                  size: 80,
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'NaruhDimana',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ingat semua, temukan segalanya',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
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
