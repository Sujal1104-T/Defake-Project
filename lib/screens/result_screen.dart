import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:defake_app/theme/app_theme.dart';
import 'package:defake_app/widgets/glass_card.dart';
import 'package:defake_app/screens/main_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:defake_app/models/scan_record.dart';
import 'package:defake_app/providers/app_state.dart';

class ResultScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  const ResultScreen({super.key, this.result = const {}});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  void initState() {
    super.initState();
    // Save to History on Load
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (widget.result.isNotEmpty) {
        final bool isDeepfake = widget.result['is_deepfake'] ?? false;
        final double confidence = (widget.result['confidence'] ?? 0.0).toDouble();
        
        context.read<AppState>().addScanResult(ScanRecord(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            fileName: "Video Scan Result",
            timestamp: DateTime.now(),
            isDeepfake: isDeepfake,
            confidence: confidence,
            type: 'upload'
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Parse Result Data from API
    final bool isDeepfake = widget.result['is_deepfake'] ?? false;
    final double confidence = (widget.result['confidence'] ?? 0.0).toDouble();
    final List<dynamic> anomalies = widget.result['anomalies'] ?? [];
    
    final Color resultColor = isDeepfake ? AppTheme.error : AppTheme.success;
    final String resultText = isDeepfake ? "DEEPFAKE DETECTED" : "REAL VIDEO";
    final IconData resultIcon = isDeepfake ? LucideIcons.alertTriangle : LucideIcons.checkCircle;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               const SizedBox(height: 20),
              // Header
               Row(
                 children: [
                   IconButton(
                     onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                          (route) => false),  
                     icon: const Icon(LucideIcons.x, color: Colors.white),
                   ),
                   const Spacer(),
                   const Text("Analysis Result"),
                   const Spacer(),
                   const SizedBox(width: 40),
                 ],
               ),
               const SizedBox(height: 40),

               // Result Indicator
               Container(
                 padding: const EdgeInsets.all(40),
                 decoration: BoxDecoration(
                   shape: BoxShape.circle,
                   border: Border.all(color: resultColor, width: 4),
                   boxShadow: [
                     BoxShadow(
                       color: resultColor.withOpacity(0.3),
                       blurRadius: 40,
                       spreadRadius: 10,
                     ),
                   ],
                 ),
                 child: Column(
                   children: [
                     Icon(resultIcon, color: resultColor, size: 64),
                     const SizedBox(height: 8),
                     Text(
                       "$confidence%",
                       style: GoogleFonts.outfit(
                         fontSize: 40,
                         fontWeight: FontWeight.bold,
                         color: resultColor,
                       ),
                     ),
                   ],
                 ),
               ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),

               const SizedBox(height: 32),

               Text(
                 resultText,
                 style: GoogleFonts.outfit(
                   fontSize: 28,
                   fontWeight: FontWeight.bold,
                   color: resultColor,
                   letterSpacing: 2,
                 ),
                 textAlign: TextAlign.center,
               ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),
              
               const SizedBox(height: 8),
               Text(
                 isDeepfake 
                 ? "High probability of AI manipulation detected."
                 : "No signs of manipulation found.",
                 style: Theme.of(context).textTheme.bodyMedium,
                 textAlign: TextAlign.center,
               ).animate().fadeIn(delay: 700.ms),

               const SizedBox(height: 40),

               // Details Section
               Text(
                 "ANOMALIES FOUND",
                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                   fontWeight: FontWeight.bold,
                   color: AppTheme.textSecondary,
                   letterSpacing: 1.5,
                 ),
               ).animate().fadeIn(delay: 800.ms),
               const SizedBox(height: 16),


               if (anomalies.isNotEmpty) ...[
                 _buildDetailRow(context, "Anomalies", "${anomalies.length} Detected", AppTheme.error, 900),
                 ...anomalies.map((a) => Padding(
                   padding: const EdgeInsets.only(left: 16.0, bottom: 8),
                   child: Row(
                     children: [
                       const Icon(LucideIcons.alertCircle, color: AppTheme.textSecondary, size: 14),
                       const SizedBox(width: 8),
                       Text(a.toString(), style: Theme.of(context).textTheme.bodySmall),
                     ],
                   ),
                 )).toList(),
               ] else ...[
                 _buildDetailRow(context, "Analysis", "Clean", AppTheme.success, 1100),
               ],

               const SizedBox(height: 40),
               
               ElevatedButton(
                onPressed: () {
                   Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                          (route) => false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "DONE",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
               ).animate().fadeIn(delay: 1500.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, Color color, int delayMs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            Row(
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  color == AppTheme.success ? LucideIcons.check : LucideIcons.alertCircle,
                  color: color,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.2, end: 0, delay: delayMs.ms).fadeIn();
  }
}
