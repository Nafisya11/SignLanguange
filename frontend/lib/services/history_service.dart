import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/detection_history.dart';

class HistoryService {
  static const String _historyKey = 'detection_history';
  static const int _maxHistoryItems = 100;
  
  // In-memory cache to avoid repeated SharedPreferences reads
  static List<DetectionHistory>? _cache;
  static DateTime? _lastCacheTime;

  static Future<void> saveDetection(String gesture, double confidence) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Use cache if available
      List<DetectionHistory> history = _cache ?? await getHistory();
      
      history.insert(0, DetectionHistory(
        gesture: gesture,
        confidence: confidence,
        timestamp: DateTime.now(),
      ));
      
      if (history.length > _maxHistoryItems) {
        history = history.sublist(0, _maxHistoryItems);
      }
      
      // Update cache
      _cache = history;
      _lastCacheTime = DateTime.now();
      
      final jsonList = history.map((h) => h.toJson()).toList();
      await prefs.setString(_historyKey, jsonEncode(jsonList));
    } catch (e) {
      // Silent error in production
    }
  }

  static Future<List<DetectionHistory>> getHistory() async {
    // Return cache if valid (less than 5 seconds old)
    if (_cache != null && _lastCacheTime != null) {
      final age = DateTime.now().difference(_lastCacheTime!);
      if (age.inSeconds < 5) {
        return _cache!;
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_historyKey);
      
      if (jsonString == null) {
        _cache = [];
        return [];
      }
      
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _cache = jsonList.map((json) => DetectionHistory.fromJson(json)).toList();
      _lastCacheTime = DateTime.now();
      return _cache!;
    } catch (e) {
      _cache = [];
      return [];
    }
  }

  static Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      _cache = [];
      _lastCacheTime = null;
    } catch (e) {
      // Silent error
    }
  }

  static Future<void> deleteHistoryItem(int index) async {
    try {
      List<DetectionHistory> history = _cache ?? await getHistory();
      
      if (index >= 0 && index < history.length) {
        history.removeAt(index);
        
        _cache = history;
        _lastCacheTime = DateTime.now();
        
        final prefs = await SharedPreferences.getInstance();
        final jsonList = history.map((h) => h.toJson()).toList();
        await prefs.setString(_historyKey, jsonEncode(jsonList));
      }
    } catch (e) {
      // Silent error
    }
  }
}
