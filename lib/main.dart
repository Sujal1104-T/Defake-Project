import 'package:defake_app/screens/login_screen.dart';
import 'package:defake_app/screens/splash_screen.dart';
import 'package:defake_app/screens/main_screen.dart';
import 'package:defake_app/services/auth_service.dart';
import 'package:defake_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';
import 'package:defake_app/providers/app_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  // Note: For web, Firebase config should be in web/index.html
  // For mobile, this will use google-services.json (Android) or GoogleService-Info.plist (iOS)
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
       apiKey: "AIzaSyBJu7aqdAi0cGHd0dx_eLFZplA3l3Fx4XE",
  authDomain: "defake-ec708.firebaseapp.com",
  projectId: "defake-ec708",
  storageBucket: "defake-ec708.firebasestorage.app",
  messagingSenderId: "77085799323",
  appId: "1:77085799323:web:40a83df7b192281ae4273e"
      ),
    );
  } catch (e) {
    print('Firebase initialization error: $e');
    // Continue anyway - you'll configure this later
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: const DefakeApp(),
    ),
  );
}

class DefakeApp extends StatelessWidget {
  const DefakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TruthGuard - Deepfake Detection',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}

// Auth routing widget - called after splash screen
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    
    return StreamBuilder(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppTheme.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        // If user is logged in, show main screen
        if (snapshot.hasData && snapshot.data != null) {
          return const MainScreen();
        }
        
        // Otherwise show login screen
        return const LoginScreen();
      },
    );
  }
}
