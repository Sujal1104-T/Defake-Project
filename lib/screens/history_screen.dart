import 'package:defake_app/models/scan_record.dart';
import 'package:defake_app/providers/app_state.dart';
import 'package:defake_app/theme/app_theme.dart';
import 'package:defake_app/widgets/glass_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Scan History"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: AppTheme.error),
            onPressed: () {
              _showClearConfirmDialog(context);
            },
          )
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final scans = appState.recentScans;

          if (scans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.history, size: 64, color: Colors.white24),
                  const SizedBox(height: 16),
                  Text(
                    "No history yet",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white30,
                        ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: scans.length,
            itemBuilder: (context, index) {
              final scan = scans[index];
              return _buildHistoryItem(context, scan, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, ScanRecord scan, int index) {
    final dateFormat = DateFormat('MMM d, h:mm a');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        child: InkWell(
          onTap: () {
            // TODO: Navigate to detail view
            // For now, show a simple dialog with details
            _showDetailDialog(context, scan);
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: scan.isDeepfake 
                        ? AppTheme.error.withOpacity(0.1) 
                        : AppTheme.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    scan.isDeepfake ? LucideIcons.alertTriangle : LucideIcons.checkCircle,
                    color: scan.isDeepfake ? AppTheme.error : AppTheme.success,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scan.fileName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${scan.type.toUpperCase()} • ${dateFormat.format(scan.timestamp)}",
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${(scan.confidence * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: scan.isDeepfake ? AppTheme.error : AppTheme.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scan.isDeepfake ? "FAKE" : "REAL",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: scan.isDeepfake ? AppTheme.error : AppTheme.success,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.1, end: 0);
  }

  void _showDetailDialog(BuildContext context, ScanRecord scan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text(scan.fileName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Result", scan.isDeepfake ? "DEEPFAKE DETECTED" : "REAL VIDEO"),
            _detailRow("Confidence", "${(scan.confidence * 100).toStringAsFixed(2)}%"),
            _detailRow("Date", DateFormat.yMMMd().add_jm().format(scan.timestamp)),
            _detailRow("Type", scan.type),
            if (scan.resultNote != null) _detailRow("Note", scan.resultNote!),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text("Clear History"),
        content: const Text("Are you sure you want to delete all scan history? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AppState>(context, listen: false).clearHistory();
              Navigator.pop(context);
            },
            child: const Text("Clear All", style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }
}
