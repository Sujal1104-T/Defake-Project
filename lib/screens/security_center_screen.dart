import 'package:defake_app/theme/app_theme.dart';
import 'package:defake_app/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SecurityCenterScreen extends StatelessWidget {
  const SecurityCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Security Center"),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.shieldCheck,
                      color: AppTheme.success,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Protected",
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: AppTheme.success,
                              ),
                        ),
                        Text(
                          "Your account is secure",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 32),

            Text(
              "SECURITY FEATURES",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
            ),
            const SizedBox(height: 16),

            _buildFeatureCard(
              context,
              LucideIcons.lock,
              "Email/Password Authentication",
              "Your account is protected with Firebase Authentication",
              AppTheme.success,
              true,
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 12),

            _buildFeatureCard(
              context,
              LucideIcons.database,
              "Encrypted Data Storage",
              "All scan results are encrypted in Firestore",
              AppTheme.success,
              true,
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 12),

            _buildFeatureCard(
              context,
              LucideIcons.userCheck,
              "Private Scan History",
              "Only you can access your scan history",
              AppTheme.success,
              true,
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 32),

            Text(
              "RECOMMENDATIONS",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
            ),
            const SizedBox(height: 16),

            _buildRecommendationCard(
              context,
              "Use a strong password",
              "Make sure your password is at least 8 characters with numbers and symbols",
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 12),

            _buildRecommendationCard(
              context,
              "Don't share your account",
              "Keep your login credentials private and secure",
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 12),

            _buildRecommendationCard(
              context,
              "Review your scans regularly",
              "Check your scan history to ensure no unauthorized activity",
            ).animate().fadeIn(delay: 700.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
    bool isActive,
  ) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          if (isActive)
            const Icon(LucideIcons.checkCircle, color: AppTheme.success, size: 20),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context, String title, String description) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.lightbulb, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
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
