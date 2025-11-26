import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_config.dart';

class ConfigCacheService {
  static const String _configKey = 'app_config_cache';
  static const String _versionKey = 'app_config_version';
  static const String _timestampKey = 'app_config_timestamp';
  
  // Cache duration: 1 hour
  static const Duration cacheDuration = Duration(hours: 1);
  
  // Save config to cache
  static Future<void> saveConfig(AppConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_configKey, json.encode(config.toJson()));
      await prefs.setInt(_versionKey, config.version);
      await prefs.setString(_timestampKey, config.updatedAt.toIso8601String());
    } catch (e) {
      // Ignore cache errors
    }
  }
  
  // Get config from cache
  static Future<AppConfig?> getCachedConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_configKey);
      final timestampStr = prefs.getString(_timestampKey);
      
      if (configJson == null || timestampStr == null) {
        return null;
      }
      
      final timestamp = DateTime.parse(timestampStr);
      final now = DateTime.now();
      
      // Check if cache is still valid
      if (now.difference(timestamp) > cacheDuration) {
        return null;
      }
      
      final configMap = json.decode(configJson) as Map<String, dynamic>;
      return AppConfig.fromJson(configMap);
    } catch (e) {
      return null;
    }
  }
  
  // Check if we need to fetch new config
  static Future<bool> shouldFetchConfig(int serverVersion) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedVersion = prefs.getInt(_versionKey) ?? 0;
      return serverVersion > cachedVersion;
    } catch (e) {
      return true;
    }
  }
  
  // Clear cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_configKey);
      await prefs.remove(_versionKey);
      await prefs.remove(_timestampKey);
    } catch (e) {
      // Ignore errors
    }
  }
}

