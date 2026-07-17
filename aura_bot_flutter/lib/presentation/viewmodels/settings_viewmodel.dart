import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsViewModel extends ChangeNotifier {
  bool _isDarkMode = true;
  String _language = 'English';
  double _fontSize = 14.0;
  bool _notificationsEnabled = true;
  bool _shareUsageData = false;
  
  String _n8nWebhookUrl = '';
  bool _isLoaded = false;

  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  double get fontSize => _fontSize;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get shareUsageData => _shareUsageData;
  String get n8nWebhookUrl => _n8nWebhookUrl;
  bool get isLoaded => _isLoaded;

  Future<void> loadSettings(String userId) async {
    if (_isLoaded) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        _n8nWebhookUrl = doc.data()?['n8nWebhookUrl'] ?? '';
        _isLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading settings from Firestore: $e");
    }
  }

  Future<void> updateN8nWebhookUrl(String url, String userId) async {
    _n8nWebhookUrl = url;
    notifyListeners();
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'n8nWebhookUrl': url,
      });
    } catch (e) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).set({
          'n8nWebhookUrl': url,
        }, SetOptions(merge: true));
      } catch (ex) {
        debugPrint("Error saving settings to Firestore: $ex");
      }
    }
  }

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void changeLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void updateFontSize(double size) {
    _fontSize = size;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void togglePrivacyUsage(bool value) {
    _shareUsageData = value;
    notifyListeners();
  }

  Future<void> clearCache() async {
    // Simulated delay for clearing database/image cache
    await Future.delayed(const Duration(seconds: 1));
    notifyListeners();
  }
}
