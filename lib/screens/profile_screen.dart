import 'package:defake_app/screens/login_screen.dart';
// import 'package:defake_app/screens/settings_screen.dart';
import 'package:defake_app/screens/security_center_screen.dart';
import 'package:defake_app/screens/help_support_screen.dart';
import 'package:defake_app/services/auth_service.dart';
import 'package:defake_app/services/firestore_service.dart';
import 'package:defake_app/models/user_model.dart';
import 'package:defake_app/theme/app_theme.dart';
import 'package:defake_app/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:defake_app/providers/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();

  Future<void> _handleSignOut() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sign Out", style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("My Profile"),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<UserModel?>(
        stream: _firestoreService.streamUserProfile(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userModel = snapshot.data;
          final appState = Provider.of<AppState>(context);
          final displayName = userModel?.displayName ?? currentUser.displayName ?? "User";
          final email = currentUser.email ?? "";
          final totalScans = userModel?.totalScans ?? appState.recentScans.length;
          final threatsDetected = userModel?.threatsDetected ?? 
              appState.recentScans.where((s) => s.isDeepfake).length;
          final safeScans = totalScans - threatsDetected;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar Section
                const SizedBox(height: 20),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primary, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: AppTheme.surfaceLight,
                          child: Text(
                            displayName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 16),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fadeIn(delay: 300.ms),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ).animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 32),

                // Stats Grid
                Row(
                  children: [
                    Expanded(child: _buildStatCard(context, "Scans", "$totalScans")),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(context, "Threats", "$threatsDetected", color: AppTheme.error)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard(context, "Safe", "$safeScans", color: AppTheme.success)),
                  ],
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 32),

                // Menu Options
                _buildMenuOption(context, LucideIcons.shield, "Security Center", "Manage protection levels", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SecurityCenterScreen()),
                  );
                }),
                const SizedBox(height: 16),
                _buildMenuOption(context, LucideIcons.helpCircle, "Help & Support", "FAQs and contact", onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                  );
                }),
                const SizedBox(height: 16),
                _buildMenuOption(
                  context,
                  LucideIcons.logOut,
                  "Sign Out",
                  "",
                  isDestructive: true,
                  onTap: _handleSignOut,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, {Color? color}) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color ?? AppTheme.textMain,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    Color iconColor = isDestructive ? AppTheme.error : AppTheme.primary;
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
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
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
                        color: isDestructive ? AppTheme.error : AppTheme.textMain,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                      ),
                  ],
                ),
              ),
              if (!isDestructive)
                const Icon(LucideIcons.chevronRight, color: AppTheme.textSecondary, size: 16),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }
}
