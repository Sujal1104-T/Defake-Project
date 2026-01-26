import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:defake_app/services/api_service.dart';
import 'package:defake_app/models/scan_record.dart';
import 'package:defake_app/theme/app_theme.dart';
import 'package:defake_app/widgets/glass_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:defake_app/providers/app_state.dart';

import 'package:flutter_background/flutter_background.dart';

import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class ScreenRecordingScreen extends StatefulWidget {
  const ScreenRecordingScreen({super.key});

  @override
  State<ScreenRecordingScreen> createState() => _ScreenRecordingScreenState();
}

class _ScreenRecordingScreenState extends State<ScreenRecordingScreen> {
  final GlobalKey _videoKey = GlobalKey();
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
      setState(() => _status = "Requesting System Permissions...");
      
      // 1. Initialize Background Service
      final androidConfig = FlutterBackgroundAndroidConfig(
        notificationTitle: "TruthGuard Active",
        notificationText: "Monitoring screen for deepfakes...",
        notificationImportance: AndroidNotificationImportance.normal,
        notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
      );
      
      bool hasPermissions = await FlutterBackground.initialize(androidConfig: androidConfig);
      print("Background Init: $hasPermissions");
      
      if (hasPermissions) {
        bool enabled = await FlutterBackground.enableBackgroundExecution();
        print("Background Enabled: $enabled");
      }

      // 2. Request Screen Share
      setState(() => _status = "Waiting for Screen Selection...");
      MediaStream stream;
      if (kIsWeb) {
        stream = await navigator.mediaDevices.getDisplayMedia({
          'video': {'cursor': 'always'},
          'audio': false
        });
      } else {
        final Map<String, dynamic> mobileConstraints = {
          'audio': false,
          'video': {
             'mandatory': {
                'width': 720,
                'height': 1280,
                'frameRate': 30,
             } // Constraints might help trigger correct picker on some devices
          }, 
        };
        // On Android, this triggers the "Start Recording" dialog
        stream = await navigator.mediaDevices.getDisplayMedia(mobileConstraints);
      }
      
      print("Stream obtained: ${stream.id}");
      if (stream.getVideoTracks().isEmpty) {
         throw Exception("No video tracks obtained from screen share.");
      }

      _localRenderer.srcObject = stream;
      _localStream = stream;

      setState(() {
        _isStreamReady = true;
        _status = "Monitoring Screen Content...";
        _statusColor = AppTheme.success;
      });
      
      context.read<AppState>().setShieldActive(true);
      _startAnalysisLoop();

      stream.getTracks()[0].onEnded = () {
        print("Stream ended by system/user.");
        if (mounted) _stopSharing();
      };

    } catch (e) {
      print("Screen Share Error: $e");
      setState(() {
        _status = "Failed: ${e.toString().split(':').last.trim()}";
        _statusColor = AppTheme.error;
      });
      
      // Delay to let user see error before resetting
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) _stopSharing(); 
    }
  }

  void _stopSharing() async {
    _monitorTimer?.cancel();
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream?.dispose();
    _localStream = null;
    _localRenderer.srcObject = null;
    
    // Stop Background Service
    if (FlutterBackground.isBackgroundExecutionEnabled) {
      await FlutterBackground.disableBackgroundExecution();
    }
    
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
    _monitorTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
       final appState = context.read<AppState>();
       if (!mounted || !appState.isShieldActive) {
         timer.cancel();
         return;
       }
       
       // Capture current frame from video stream
       try {
         if (_localRenderer.srcObject == null) return;
         
         // On web, RepaintBoundary cannot capture RTCVideoView (Video Element)
         // So we skip frame analysis to prevent crashes/errors.
         if (kIsWeb) {
           return;
         }
         
         // Get video track
         final videoTrack = _localStream?.getVideoTracks().firstOrNull;
         if (videoTrack == null) return;
         
         // Capture frame as image using RepaintBoundary
         if (_videoKey.currentContext == null) return;
         
         final boundary = _videoKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
         if (boundary == null) return;

         // Convert to image
         final image = await boundary.toImage();
         final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
         if (byteData == null) return;
         
         final imageData = byteData.buffer.asUint8List();
         
         // Send to backend for analysis
         final result = await ApiService.analyzeFrame(imageData);
         
         if (!mounted) return;
         
         // Update UI based on result
         if (result['is_deepfake'] == true) {
           final confidence = result['confidence'] ?? 0.0;
           setState(() {
             _status = "⚠️ Deepfake Detected! (${(confidence * 100).toInt()}%)";
             _statusColor = AppTheme.error;
           });
           
           final record = ScanRecord(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              fileName: "Screen Capture",
              timestamp: DateTime.now(),
              isDeepfake: true,
              confidence: confidence,
              type: 'monitor',
            );
            
            // Add to recent scans
            appState.addScanResult(record);
           
           // Show alert
           if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text("⚠️ Deepfake detected on screen!"),
                 backgroundColor: AppTheme.error,
                 duration: Duration(seconds: 3),
               ),
             );
           }
         } else {
           setState(() {
             _status = "✓ Monitoring... All Clear";
             _statusColor = AppTheme.success;
           });
         }
       } catch (e) {
         print("Analysis error: $e");
         // Continue monitoring even if one frame fails
       }
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
                 child: RepaintBoundary(
                   key: _videoKey,
                   child: RTCVideoView(
                      _localRenderer,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                   ),
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
