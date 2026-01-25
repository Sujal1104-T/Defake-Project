import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // TODO: REPLACE this with your actual Render/Railway URL after deployment
  // Example: "https://truthguard-backend.onrender.com"
  static const String _productionUrl = ""; 

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

  static Future<Map<String, dynamic>> analyzeVideo(PlatformFile file) async {
    final uri = Uri.parse("$baseUrl/analyze");
    
    var request = http.MultipartRequest('POST', uri);
    
    // On Web, path is null, use bytes.
    if (file.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
          contentType: MediaType('video', 'mp4'), 
        ),
      );
    } else if (file.path != null) {
      // On Mobile/Desktop, use path.
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', 
          file.path!,
          filename: file.name,
        ),
      );
    } else {
      throw Exception("Invalid file: No bytes or path found.");
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Server Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      throw Exception("Failed to connect to API: $e");
    }
  }

  static Future<Map<String, dynamic>> analyzeFrame(List<int> imageBytes) async {
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
      final streamedResponse = await request.send();
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
}
