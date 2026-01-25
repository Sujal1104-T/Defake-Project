import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:defake_app/models/scan_record.dart';
import 'package:defake_app/services/firestore_service.dart';
import 'package:defake_app/services/auth_service.dart';

class AppState extends ChangeNotifier {
  bool _isShieldActive = false;
  String _shieldStatus = "System Idle";
  
  List<ScanRecord> _recentScans = [];
  final List<String> _notifications = [];
  
  final _firestoreService = FirestoreService();
  final _authService = AuthService();

  bool get isShieldActive => _isShieldActive;
  String get shieldStatus => _shieldStatus;
  List<ScanRecord> get recentScans => List.unmodifiable(_recentScans);
  List<String> get notifications => List.unmodifiable(_notifications);

  AppState() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? historyJson = prefs.getString('scan_history');
    if (historyJson != null) {
      final List<dynamic> decoded = jsonDecode(historyJson);
      _recentScans = decoded.map((item) => ScanRecord.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_recentScans.map((e) => e.toJson()).toList());
    await prefs.setString('scan_history', encoded);
  }

  Future<void> clearHistory() async {
    _recentScans.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scan_history');
    
    // Also clear from Firestore if user is logged in
    final user = _authService.currentUser;
    if (user != null) {
      try {
        await _firestoreService.clearUserHistory(user.uid);
      } catch (e) {
        print('Error clearing Firestore history: $e');
      }
    }
    
    notifyListeners();
  }

  void setShieldActive(bool isActive) {
    if (_isShieldActive == isActive) return; 

    _isShieldActive = isActive;
    _shieldStatus = isActive ? "Active Shield Monitoring" : "System Idle";
    
    if (isActive) {
      _notifications.insert(0, "🛡️ Active Shield turned ON");
    } else {
      _notifications.insert(0, "⏸️ Active Shield turned OFF");
    }
    notifyListeners();
  }

  void updateStatus(String status) {
    if (_shieldStatus != status) {
       _shieldStatus = status;
       if (status.contains("ALERT")) {
          _notifications.insert(0, "🚨 $status");
          
          // Add to History
          final record = ScanRecord(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            fileName: "Live Monitor Stream",
            timestamp: DateTime.now(),
            isDeepfake: true,
            confidence: 90.0,
            type: 'monitor'
          );
          _recentScans.insert(0, record);
          _saveHistory();
          
          // Sync to Firestore
          _syncToFirestore(record, isThreat: true);
       }
       notifyListeners();
    }
  }
  
  void addScanResult(ScanRecord record) {
    _recentScans.insert(0, record);
    _notifications.insert(0, "${record.isDeepfake ? '⚠️' : '✅'} Analyzed ${record.fileName}");
    _saveHistory();
    
    // Sync to Firestore
    _syncToFirestore(record, isThreat: record.isDeepfake);
    
    notifyListeners();
  }
  
  Future<void> _syncToFirestore(ScanRecord record, {required bool isThreat}) async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        // Save scan to cloud
        await _firestoreService.saveScanToCloud(user.uid, record);
        // Update user stats
        await _firestoreService.incrementScanCount(user.uid, isThreat: isThreat);
      } catch (e) {
        print('Error syncing to Firestore: $e');
        // Continue silently - local data is still saved
      }
    }
  }
  
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;
}
