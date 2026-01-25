import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:defake_app/screens/result_screen.dart';
import 'package:defake_app/services/api_service.dart';
import 'package:defake_app/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UploadAnalysisScreen extends StatefulWidget {
  final bool isVideo;
  const UploadAnalysisScreen({super.key, required this.isVideo});

  @override
  State<UploadAnalysisScreen> createState() => _UploadAnalysisScreenState();
}

class _UploadAnalysisScreenState extends State<UploadAnalysisScreen> {
  double _progress = 0.0;
  String _status = "Waiting for file...";
  bool _isAnalyzing = false;
  bool _isError = false;
  String _errorMessage = "";
  PlatformFile? _pickedFile;

  @override
  void initState() {
    super.initState();
    // Simulate initial delay or instruction
    if (widget.isVideo) {
       _pickFile();
    } else {
      // Camera logic would go here
       _status = "Select Video to Analyze";
    }
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
        withData: true, // Important for Web
      );

      if (result != null) {
        setState(() {
          _pickedFile = result.files.first;
          _status = "File Selected: ${_pickedFile!.name}";
        });
        _startUploadAndAnalyze();
      } else {
        // User canceled
         setState(() {
           _status = "No file selected.";
         });
      }
    } catch (e) {
       setState(() {
        _isError = true;
        _errorMessage = "Picker Error: $e";
      });
    }
  }

  Future<void> _startUploadAndAnalyze() async {
    if (_pickedFile == null) return;

    setState(() {
      _isAnalyzing = false;
      _progress = 0.0;
      _status = "Uploading ${_pickedFile!.name}...";
    });

    // Simulate Upload Progress visuals (since MultipartRequest doesn't easily give progress stream without custom client)
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _progress += 0.05;
        if (_progress >= 0.9) {
          _progress = 0.95; // Hold at 95% until response
          timer.cancel();
          _callApi();
        }
      });
    });
  }

  Future<void> _callApi() async {
    setState(() {
      _isAnalyzing = true;
      _status = "AI Engine Analyzing Frames...";
    });

    try {
      final result = await ApiService.analyzeVideo(_pickedFile!);
      
      if (mounted) {
         Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ResultScreen(result: result)),
        );
      }
    } catch (e) {
      setState(() {
        _isError = true;
        _errorMessage = e.toString();
        _status = "Analysis Failed";
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text("Analyze Video"),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isError) ...[
                 const Icon(LucideIcons.alertTriangle, color: AppTheme.error, size: 64),
                 const SizedBox(height: 16),
                 Text(
                   "Error Occurred",
                   style: Theme.of(context).textTheme.displaySmall,
                   textAlign: TextAlign.center,
                 ),
                 const SizedBox(height: 8),
                 Text(
                   _errorMessage,
                   textAlign: TextAlign.center,
                   style: Theme.of(context).textTheme.bodyMedium,
                 ),
                 const SizedBox(height: 24),
                 ElevatedButton(
                   onPressed: () {
                     setState(() {
                       _isError = false;
                       _errorMessage = "";
                     });
                     _pickFile();
                   },
                   child: const Text("Try Again"),
                 )
              ] else if (!_isAnalyzing && _pickedFile == null) ...[
                 InkWell(
                   onTap: _pickFile,
                   borderRadius: BorderRadius.circular(20),
                   child: Container(
                     padding: const EdgeInsets.all(40),
                     decoration: BoxDecoration(
                       color: AppTheme.surfaceLight.withOpacity(0.5),
                       shape: BoxShape.circle,
                       border: Border.all(color: AppTheme.primary, width: 2),
                     ),
                     child: const Icon(LucideIcons.uploadCloud, size: 60, color: AppTheme.primary),
                   ),
                 ).animate().scale(duration: 500.ms),
                 const SizedBox(height: 24),
                 Text(
                   "Tap to Upload Video",
                   style: Theme.of(context).textTheme.headlineSmall,
                 ),
                 const SizedBox(height: 8),
                 Text(
                   "Supports MP4, MOV, AVI",
                   style: Theme.of(context).textTheme.bodyMedium,
                 ),
              ] else if (!_isAnalyzing && _pickedFile != null && _progress < 1.0) ...[
                // Upload Progress Circle
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 8,
                        backgroundColor: AppTheme.surfaceLight,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondary),
                      ),
                      Center(
                        child: Text(
                          "${(_progress * 100).toInt()}%",
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                 // Analysis Animation (Grid/Face Scan Simulation)
                 Stack(
                   alignment: Alignment.center,
                   children: [
                     Container(
                       width: 200,
                       height: 200,
                       decoration: BoxDecoration(
                         border: Border.all(color: AppTheme.primary, width: 2),
                         borderRadius: BorderRadius.circular(16),
                       ),
                       child: GridView.builder(
                         itemCount: 16,
                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                         itemBuilder: (context, index) {
                           return Container(
                             margin: const EdgeInsets.all(4),
                             decoration: BoxDecoration(
                               color: AppTheme.primary.withOpacity(0.1),
                               shape: BoxShape.circle,
                             ),
                           ).animate(
                             onPlay: (c) => c.repeat(),
                             delay: (index * 50).ms,
                           ).fade(duration: 1.seconds);
                         },
                       ),
                     ),
                     Container(
                       height: 2,
                       width: 200,
                       color: AppTheme.error,
                     ).animate(onPlay: (c) => c.repeat(reverse: true)).slideY(begin: -50, end: 50, duration: 2.seconds),
                   ],
                 ),
                  const SizedBox(height: 32),
                 Text(
                  _status,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ).animate().shimmer(color: AppTheme.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
