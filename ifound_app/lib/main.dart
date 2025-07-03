import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:ifound_app/services/simple_notification_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:ifound_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ifound_app/providers/theme_provider.dart';
import 'package:ifound_app/providers/connection_provider.dart';
import 'package:ifound_app/screens/splash_screen.dart';
import 'package:ifound_app/screens/onboarding_screen.dart';
import 'package:ifound_app/screens/login_screen.dart';
import 'package:ifound_app/screens/main_shell.dart';
import 'package:ifound_app/components/connection_indicator.dart';
import 'package:ifound_app/localization/kinyarwanda_delegate.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local notification service (no Firebase messaging)
  try {
    await NotificationService().initialize();
  } catch (e) {
  }

  // Initialize Easy Localization
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr'), Locale('rw')],
      path: 'assets',
      fallbackLocale: const Locale('en'),
      useOnlyLangCode: true,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final themeProvider = ThemeProvider();
          // Load theme immediately
          themeProvider.loadTheme();
          return themeProvider;
        }),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'iFound',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: [
              ...context.localizationDelegates,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              KinyarwandaMaterialLocalizationsDelegate(),
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('fr'),
              Locale('rw'),
            ],
                        locale: context.locale,

            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthWrapper(),
            builder: (context, child) {
              return Stack(
                children: [
                  child!,
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ConnectionIndicator(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Get current user immediately
      _currentUser = FirebaseAuth.instance.currentUser;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
          return const SplashScreen();
        }

        // Handle errors in auth state stream
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Authentication Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please restart the app',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }

        // User is authenticated - check both stream and current user
        final user = snapshot.data ?? _currentUser;
        if (user != null) {
          // Set user ID in theme provider for user-specific settings
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              final themeProvider =
                  Provider.of<ThemeProvider>(context, listen: false);
              themeProvider.userId = user.uid;
            } catch (e) {
              // Handle error silently
            }
          });

          return const MainShell();
        }

        // User is not authenticated - check onboarding status
        return FutureBuilder<bool>(
          future: _hasSeenOnboarding(),
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
            }

            if (onboardingSnapshot.hasError) {
              // If onboarding check fails, show login screen
              return const LoginScreen();
            }

            if (onboardingSnapshot.data == false) {
              return const OnboardingScreen();
            }

            return const LoginScreen();
          },
        );
      },
    );
  }

  Future<bool> _hasSeenOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('has_seen_onboarding') ?? false;
    } catch (e) {
      return false;
    }
  }
}
