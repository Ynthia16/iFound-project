import 'package:flutter/material.dart';
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
    print('Failed to initialize notification service: $e');
  }

  // Initialize Easy Localization
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('fr')],
      path: 'assets',
      fallbackLocale: const Locale('en'),
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'iFound',
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
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

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }

        if (snapshot.hasData && snapshot.data != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
            themeProvider.userId = snapshot.data!.uid;
          });
          
          return const MainShell();
        }

        return FutureBuilder<bool>(
          future: _hasSeenOnboarding(),
          builder: (context, onboardingSnapshot) {
            if (onboardingSnapshot.connectionState == ConnectionState.waiting) {
              return const SplashScreen();
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