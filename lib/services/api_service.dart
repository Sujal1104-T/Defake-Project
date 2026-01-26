import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // TODO: REPLACE this with your actual Render/Railway URL after deployment
  // Example: "https://truthguard-backend.onrender.com"
  static const String _productionUrl = "https://defake-backend-437i.onrender.com"; 
  
  // Fallback to localhost if production is down (for development)
  static const bool _useLocalFallback = true;

  static String get baseUrl {
    // If we have a production URL and we are on Web or in Release mode, use it
    if (_productionUrl.isNotEmpty) {
      if (kIsWeb || kReleaseMode) return _productionUrl;
    }

    if (kIsWeb) return "http://127.0.0.1:8000";
    // Android Emulator uses 10.0.2.2 to access host localhost
    if (defaultTargetPlatform == TargetPlatform.android) return "http://10.0.2.2:8000"; 
    // iOS Simulator uses localhost
    return "http://127.0.0.1:8000";
  } 

  static final http.Client _client = http.Client();

  static Future<Map<String, dynamic>> analyzeVideo(PlatformFile file) async {
    final uri = Uri.parse("$baseUrl/analyze");
    
    // Create a new request (MultipartRequest cannot be reused)
    var request = http.MultipartRequest('POST', uri);
    
    // On Web, always use bytes
    if (kIsWeb) {
       if (file.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              file.bytes!,
              filename: file.name,
              contentType: MediaType('video', 'mp4'), 
            ),
          );
       } else {
          throw Exception("File bytes missing on Web. Please retry.");
       }
    } else {
        // ... (Mobile/Desktop logic remains same, just shorter for brevity in this replace block if possible, but strict replace needed)
        // On Mobile/Desktop
        if (file.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'file', 
              file.path!,
              filename: file.name,
            ),
          );
        } else if (file.bytes != null) {
           request.files.add(
            http.MultipartFile.fromBytes(
              'file',
              file.bytes!,
              filename: file.name,
              contentType: MediaType('video', 'mp4'), 
            ),
          );
        }
    }
    
    if (request.files.isEmpty) {
      throw Exception("Invalid file: No bytes or path found.");
    }

    try {
      // Use the shared client to send - this helps with connection reuse/pooling
      // We send the request via the client
      final streamedResponse = await _client.send(request).timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Server Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('connection') || errorMsg.contains('closed')) {
         // Retry logic could go here, or just a clearer message
         throw Exception("Connection failed. Please check internet or try again. ($e)");
      }
      if (errorMsg.contains('render')) {
         throw Exception("Backend sleeping. Please wait 30s and retry.");
      }
      throw Exception("Analysis Error: $e");
    }
  }

  static Future<Map<String, dynamic>> analyzeFrame(Uint8List imageBytes) async {
    final uri = Uri.parse("$baseUrl/analyze_frame");
    
    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file', 
        imageBytes,
        filename: 'frame.jpg', 
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    try {
      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Return null or error object for frame errors so stream continues
        print("Frame error: ${response.body}");
        return {"is_deepfake": false, "confidence": 0.0};
      }
    } catch (e) {
      print("Frame connection error: $e");
      return {"is_deepfake": false, "confidence": 0.0};
    }
  }
  static Future<Map<String, dynamic>> fetchLearnUpdates() async {
    final uri = Uri.parse("$baseUrl/learn/updates");
    try {
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Failed to load updates");
      }
    } catch (e) {
      print("Learn API Error: $e");
      // Return fallback data so UI doesn't break
      return {
        "tip_of_the_day": "Stay skeptical. Verify the source of any sensational video.",
        "insights": [] 
      };
    }
  }
  static Future<void> wakeUp() async {
    // Fire and forget ping to wake up Render backend
    try {
      final uri = Uri.parse(baseUrl);
      // Timeout is short because we don't assume we'll get a quick response during cold boot,
      // but the request itself triggers the wake up.
      await http.get(uri).timeout(const Duration(seconds: 5));
      print("Wake-up ping sent to $baseUrl");
    } catch (e) {
      // It's expected to timeout or fail if sleeping deeply, but the request still wakes it up.
      print("Wake-up ping initiated: $e");
    }
  }
}
