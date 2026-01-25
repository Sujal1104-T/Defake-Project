import 'package:defake_app/screens/notifications_screen.dart';
import 'package:defake_app/screens/screen_recording_screen.dart';
import 'package:defake_app/screens/upload_analysis_screen.dart';
import 'package:defake_app/theme/app_theme.dart';
import 'package:defake_app/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:defake_app/providers/app_state.dart';
import 'package:defake_app/screens/history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_outlined, color: AppTheme.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              "TRUTHGUARD",
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontSize: 22,
                    letterSpacing: 2,
                  ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Status Header (Smaller now)
            // Quick Status Header (Dynamic)
            Consumer<AppState>(
              builder: (context, appState, _) {
                final isActive = appState.isShieldActive;
                final color = isActive ? AppTheme.success : Colors.grey;
                
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                         color: color.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(20),
                         border: Border.all(color: color.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isActive ? LucideIcons.checkCircle : LucideIcons.minusCircle, 
                            color: color, 
                            size: 14
                          ),
                          const SizedBox(width: 6),
                          Text(
                            appState.shieldStatus,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 12
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(LucideIcons.bell, color: Colors.white, size: 20),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      ),
                    ),
                  ],
                );
              },
            ).animate().fadeIn(),
            
            const SizedBox(height: 32),
            Text(
              "Quick Actions",
              style: Theme.of(context).textTheme.displayMedium,
            ).animate().slideX(begin: -0.1, end: 0),
            const SizedBox(height: 16),

            // Main Hero Action - Record
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UploadAnalysisScreen(isVideo: false)),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                height: 180,
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(LucideIcons.camera, color: Colors.white, size: 28),
                          ),
                          const Spacer(),
                          const Text(
                            "Scan Face",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            "Live Detection",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(LucideIcons.scanLine, size: 100, color: Colors.white24),
                  ],
                ),
              ),
            ).animate().scale(delay: 200.ms),

            const SizedBox(height: 16),

            // Secondary Actions Row
            Row(
              children: [
                Expanded(
                  child: _buildActionBtn(
                    context,
                    "Upload",
                    "Analyze file",
                    LucideIcons.uploadCloud,
                    AppTheme.surfaceLight,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UploadAnalysisScreen(isVideo: true)),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionBtn(
                    context,
                    "Monitor",
                    "Screen Guard",
                    LucideIcons.monitorPlay,
                    AppTheme.surfaceLight,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ScreenRecordingScreen()),
                      );
                    },
                  ),
                ),
              ],
            ).animate().slideY(begin: 0.1, end: 0, delay: 300.ms),
            
            const SizedBox(height: 32),

            // Recent Activity Snippet
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Activity",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistoryScreen()),
                    );
                  },
                  child: const Text(
                    "See All",
                    style: TextStyle(color: AppTheme.primary, fontSize: 14),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),
            
            Consumer<AppState>(
              builder: (context, appState, _) {
                 if (appState.recentScans.isEmpty) {
                   return Center(
                     child: Padding(
                       padding: const EdgeInsets.all(20.0),
                       child: Text(
                         "No scans yet", 
                         style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white30),
                       ),
                     ),
                   );
                 }
                 
                 return Column(
                   children: appState.recentScans.take(3).map((scan) {
                     return Padding(
                       padding: const EdgeInsets.only(bottom: 12.0),
                       child: GlassCard(
                         child: Row(
                           children: [
                             Icon(
                               scan.isDeepfake ? LucideIcons.alertTriangle : LucideIcons.checkCircle, 
                               color: scan.isDeepfake ? AppTheme.error : AppTheme.success
                             ),
                             const SizedBox(width: 12),
                             Expanded(
                               child: Text(
                                 scan.isDeepfake ? "Deepfake Detected" : "Verified Real",
                                 style: Theme.of(context).textTheme.bodyMedium,
                               ),
                             ),
                             Text(
                               // Simple time formatter or just 'now' for demo
                               "${DateTime.now().difference(scan.timestamp).inMinutes}m ago",
                               style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
                             ),
                           ],
                         ),
                       ),
                     );
                   }).toList(),
                 );
              },
            ).animate().slideX(begin: 0.1, end: 0, delay: 500.ms),

          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
