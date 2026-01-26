import 'package:defake_app/services/api_service.dart';
import 'package:defake_app/theme/app_theme.dart';
import 'package:defake_app/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key});

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  Future<Map<String, dynamic>>? _updatesFuture;

  @override
  void initState() {
    super.initState();
    _updatesFuture = ApiService.fetchLearnUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Deepfake Academy"),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _updatesFuture,
        builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
           }
           
           final data = snapshot.data ?? {};
           final tip = data['tip_of_the_day'] ?? "Stay alert and safe.";
           final insights = data['insights'] as List? ?? [];

           return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildFeaturedCard(context, tip),
                const SizedBox(height: 24),
                Text(
                  "LATEST INSIGHTS",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 16),
                
                if (insights.isEmpty)
                   const Center(child: Text("No new articles right now.", style: TextStyle(color: Colors.white54))),

                ...insights.asMap().entries.map((entry) {
                   final idx = entry.key;
                   final article = entry.value;
                   return _buildArticleCard(
                     context,
                     article['title'] ?? "Unknown Title",
                     article['summary'] ?? "No summary available.",
                     LucideIcons.newspaper,
                     idx % 2 == 0 ? AppTheme.secondary : Colors.orange,
                     200 + (idx * 100),
                     article['source'] ?? "Unknown Source",
                   );
                }),
              ],
           );
        },
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, String tip) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 200),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [AppTheme.primary.withOpacity(0.2), AppTheme.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              LucideIcons.lightbulb,
              size: 150,
              color: AppTheme.primary.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "TIP OF THE DAY",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  tip,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                   children: [
                     Icon(LucideIcons.checkCircle, size: 16, color: AppTheme.success.withOpacity(0.8)),
                     const SizedBox(width: 8),
                     Text(
                       "Verified by AI Research Ops",
                       style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                     )
                   ],
                )
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.2, end: 0, duration: 600.ms).fadeIn();
  }

  Widget _buildArticleCard(
      BuildContext context, String title, String subtitle, IconData icon, Color color, int delay, String source) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: EdgeInsets.zero, // Remove padding from container to let InkWell fill it
        child: InkWell(
          onTap: () => _showInsightDetails(context, title, subtitle, source),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
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
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(LucideIcons.chevronRight, color: AppTheme.textSecondary, size: 16),
              ],
            ),
          ),
        ),
      ),
    ).animate().slideX(begin: 0.1, end: 0, delay: delay.ms).fadeIn();
  }

  void _showInsightDetails(BuildContext context, String title, String summary, String source) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Source: $source",
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                summary,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Close"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
