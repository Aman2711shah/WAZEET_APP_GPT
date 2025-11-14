import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as p;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'app_router.dart';
import 'services/auth_token_service.dart';
import 'services/auth_service.dart';
import 'theme/theme_controller.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables (optional - may not exist in production)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('No .env file found - using default configuration: $e');
  }

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize auth token monitoring
    AuthTokenService.initialize();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    // Re-throw to prevent app from running with broken Firebase
    rethrow;
  }

  final themeController = await ThemeController.load();
  runApp(
    ProviderScope(
      child: p.ChangeNotifierProvider.value(
        value: themeController,
        child: const WazeetApp(),
      ),
    ),
  );
}

class WazeetApp extends StatelessWidget {
  const WazeetApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Force light mode only - dark mode disabled
    return MaterialApp(
      title: 'WAZEET',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      home: AppRouter(authService: AuthService()),
      builder: (context, child) {
        // Apply system UI overlay for light theme only
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            statusBarIconBrightness: Brightness.dark,
          ),
        );
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
