import 'package:defake_app/theme/app_theme.dart';
import 'package:defake_app/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Help & Support"),
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
            Text(
              "How can we help you?",
              style: Theme.of(context).textTheme.displayMedium,
            ).animate().fadeIn(),

            const SizedBox(height: 8),

            Text(
              "Find answers to common questions or contact us",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 32),

            Text(
              "FREQUENTLY ASKED QUESTIONS",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
            ),
            const SizedBox(height: 16),

            _buildFAQItem(
              context,
              "How does deepfake detection work?",
              "Our system uses XceptionNet, a deep learning model trained on thousands of real and fake videos to detect subtle manipulations.",
            ).animate().fadeIn(delay: 200.ms),

            _buildFAQItem(
              context,
              "Is my data safe?",
              "Yes! All your data is encrypted and stored securely in Firebase. Only you can access your scan history.",
            ).animate().fadeIn(delay: 300.ms),

            _buildFAQItem(
              context,
              "Can I use this offline?",
              "Currently, the app requires an internet connection to analyze videos using our backend server.",
            ).animate().fadeIn(delay: 400.ms),

            _buildFAQItem(
              context,
              "What video formats are supported?",
              "We support MP4, AVI, MOV, and other common video formats. The file size should be under 100MB for best results.",
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 32),

            Text(
              "CONTACT US",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
            ),
            const SizedBox(height: 16),

            _buildContactCard(
              context,
              LucideIcons.mail,
              "Email Support",
              "support@defake.com",
              () => _launchEmail(),
            ).animate().fadeIn(delay: 600.ms),

            const SizedBox(height: 12),

            _buildContactCard(
              context,
              LucideIcons.github,
              "GitHub",
              "Report issues or contribute",
              () => _launchURL('https://github.com'),
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 12),

            _buildContactCard(
              context,
              LucideIcons.globe,
              "Website",
              "Visit our website",
              () => _launchURL('https://defake.com'),
            ).animate().fadeIn(delay: 800.ms),

            const SizedBox(height: 32),

            Center(
              child: Text(
                "Version 1.0.0 (Beta)\nDefake © 2026",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ).animate().fadeIn(delay: 900.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(LucideIcons.helpCircle, color: AppTheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: Text(
              answer,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildContactCard(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GlassCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.primary, size: 24),
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
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.externalLink, color: AppTheme.textSecondary, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@defake.com',
      query: 'subject=Defake Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
