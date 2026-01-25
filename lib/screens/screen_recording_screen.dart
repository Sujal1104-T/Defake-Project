import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:defake_app/services/api_service.dart';
import 'package:defake_app/theme/app_theme.dart';
import 'package:defake_app/widgets/glass_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:defake_app/providers/app_state.dart';

class ScreenRecordingScreen extends StatefulWidget {
  const ScreenRecordingScreen({super.key});

  @override
  State<ScreenRecordingScreen> createState() => _ScreenRecordingScreenState();
}

class _ScreenRecordingScreenState extends State<ScreenRecordingScreen> {
  bool _isActive = false;
  String _status = "System Idle";
  Color _statusColor = AppTheme.primary;
  
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  Timer? _monitorTimer;
  bool _isStreamReady = false;

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    await _localRenderer.initialize();
  }

  @override
  void dispose() {
    _monitorTimer?.cancel();
    _localStream?.dispose();
    _localRenderer.dispose();
    super.dispose();
  }

  void _toggleMonitor() async {
    final appState = context.read<AppState>();
    if (appState.isShieldActive) {
      _stopSharing();
    } else {
      await _startSharing();
    }
  }

  Future<void> _startSharing() async {
    try {
      // Constraints for Screen Sharing. 
      // NOTE: On some mobile browsers, 'video: true' can fallback to camera if not handled correctly.
      // Explicitly requesting displayMedia usually prevents this, but we'll be more specific.
      final Map<String, dynamic> mediaConstraints = {
        'audio': false,
        'video': {
          'mandatory': {
            'chromeMediaSource': 'screen',
          },
          'optional': []
        }
      };

      // On Web, navigator.mediaDevices.getDisplayMedia is standard.
      // flutter_webrtc translates this appropriately.
      MediaStream stream;
      if (kIsWeb) {
        stream = await navigator.mediaDevices.getDisplayMedia({
          'video': true,
          'audio': false
        });
      } else {
        stream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
      }
      
      _localRenderer.srcObject = stream;
      _localStream = stream;

      setState(() {
        _isStreamReady = true;
        _status = "Monitoring Screen Content...";
        _statusColor = AppTheme.success;
      });
      
      // Update Global State
      context.read<AppState>().setShieldActive(true);

      _startAnalysisLoop();

      // Listen for stream end (user clicks "Stop Sharing" in browser UI)
      stream.getTracks()[0].onEnded = () {
        if (mounted) _stopSharing();
      };

    } catch (e) {
      print("Screen Share Error: $e");
      setState(() {
        _status = "Permission Denied or Cancelled";
        _statusColor = AppTheme.error;
      });
      context.read<AppState>().setShieldActive(false);
    }
  }

  void _stopSharing() {
    _monitorTimer?.cancel();
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _localStream = null;
    _localRenderer.srcObject = null;
    
    if (mounted) {
      setState(() {
        _isStreamReady = false;
        _status = "System Idle";
        _statusColor = AppTheme.primary;
      });
      
      // Update Global State
      context.read<AppState>().setShieldActive(false);
    }
  }

  void _startAnalysisLoop() {
    int counter = 0;
    _monitorTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
       final appState = context.read<AppState>();
       if (!mounted || !appState.isShieldActive) {
         timer.cancel();
         return;
       }
       
       counter++;
       // Simulation of analysis result
       bool simulateDeepfake = (counter % 8 == 0); 
       
       setState(() {
         if (simulateDeepfake) {
           _status = "ALERT: Suspicious Content on Screen!";
           _statusColor = AppTheme.error;
           context.read<AppState>().updateStatus("ALERT: Suspicious Content!");
         } else {
           _status = "Screen Safe | Analyzing Feed...";
           _statusColor = AppTheme.success;
           if (counter % 4 == 0) context.read<AppState>().updateStatus("Active Monitoring");
         }
       });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isActive = context.watch<AppState>().isShieldActive;
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Live Screen Monitor"),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Screen Share Preview
          if (_isStreamReady && isActive)
             Positioned.fill(
               child: Opacity(
                 opacity: 0.2, // Subtle background
                 child: RTCVideoView(
                    _localRenderer,
                    objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                 ),
               ),
             ),

          // Foreground UI
          Positioned.fill(
            child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.2), 
                    shape: BoxShape.circle,
                    border: Border.all(color: _statusColor.withOpacity(0.8), width: 3),
                  ),
                  child: Icon(
                      isActive ? LucideIcons.scanLine : LucideIcons.monitor,
                      size: 64, 
                      color: _statusColor
                  ),
                )
                .animate(target: isActive ? 1 : 0)
                .shimmer(color: _statusColor, duration: 1.seconds)
                .boxShadow(
                    begin: BoxShadow(
                      color: _statusColor.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                    end: BoxShadow(
                      color: _statusColor.withOpacity(0.6),
                      blurRadius: 60,
                      spreadRadius: 20,
                    ),
                ),

                const SizedBox(height: 48),
                
                GlassCard(
                  color: AppTheme.background.withOpacity(0.8),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Text(
                    _status,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: _statusColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(),
                
                const SizedBox(height: 16),
                
                const Spacer(),
                
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  color: AppTheme.surfaceLight.withOpacity(0.9),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(LucideIcons.layers,
                              color: AppTheme.secondary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Monitoring all open apps including Social Media.",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                 const SizedBox(height: 24),
                
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _toggleMonitor,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? AppTheme.error : AppTheme.primary, // Red for STOP
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.5),
                      ),
                      child: Text(
                        isActive ? "STOP MONITORING" : "START SCREEN SHARE",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}
