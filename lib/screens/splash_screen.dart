import 'package:defake_app/screens/main_screen.dart';
import 'package:defake_app/main.dart'; // For AuthGate
import 'package:defake_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const AuthGate()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI Logo Simulation
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                )
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.1, 1.1), duration: 2.seconds),
                
                const Icon(
                  Icons.shield_outlined,
                  size: 64,
                  color: AppTheme.textMain,
                ).animate().fadeIn(duration: 1.seconds).shimmer(delay: 1.seconds, color: AppTheme.primary),
              ],
            ),
            const SizedBox(height: 32),
            // Title
            Text(
              "TRUTHGUARD",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    letterSpacing: 4,
                  ),
            ).animate().slideY(begin: 0.2, end: 0, duration: 800.ms).fadeIn(),
            const SizedBox(height: 12),
            // Tagline
            Text(
              "Verify Faces. Detect Deepfakes.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primary,
                  ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }
}
