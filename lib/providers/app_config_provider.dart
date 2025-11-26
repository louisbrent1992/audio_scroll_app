import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/app_config.dart';
import '../services/api_service.dart';
import '../services/config_cache_service.dart';
import '../theme/app_theme.dart';

class AppConfigProvider with ChangeNotifier {
  AppConfig? _config;
  bool _isLoading = false;
  String? _error;
  
  AppConfig? get config => _config;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Get theme colors from config or defaults
  Color get primaryColor => _config?.theme.primaryColorValue ?? AppTheme.primaryColor;
  Color get secondaryColor => _config?.theme.secondaryColorValue ?? AppTheme.secondaryColor;
  Color get accentColor => _config?.theme.accentColorValue ?? AppTheme.accentColor;
  Color get highlightColor => _config?.theme.highlightColorValue ?? AppTheme.highlightColor;
  Color get surfaceColor => _config?.theme.surfaceColorValue ?? AppTheme.surfaceColor;
  Color get backgroundColor => _config?.theme.backgroundColorValue ?? AppTheme.backgroundColor;
  Color get textPrimary => _config?.theme.textPrimaryValue ?? AppTheme.textPrimary;
  Color get textSecondary => _config?.theme.textSecondaryValue ?? AppTheme.textSecondary;
  Color get textTertiary => _config?.theme.textTertiaryValue ?? AppTheme.textTertiary;
  
  // Feature flags
  bool get enableBanners => _config?.features.enableBanners ?? true;
  bool get enableSpotlight => _config?.features.enableSpotlight ?? true;
  bool get enableOnboarding => _config?.features.enableOnboarding ?? true;
  
  Future<void> loadConfig({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Try to load from cache first (unless force refresh)
      if (!forceRefresh) {
        final cachedConfig = await ConfigCacheService.getCachedConfig();
        if (cachedConfig != null) {
          _config = cachedConfig;
          _isLoading = false;
          notifyListeners();
          
          // Check if we need to fetch new version in background
          final serverConfig = await ApiService.getAppConfig();
          if (serverConfig.version > cachedConfig.version) {
            _config = serverConfig;
            await ConfigCacheService.saveConfig(serverConfig);
            notifyListeners();
          }
          return;
        }
      }
      
      // Fetch from server
      final serverConfig = await ApiService.getAppConfig();
      _config = serverConfig;
      await ConfigCacheService.saveConfig(serverConfig);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      
      // Try to use cached config as fallback
      final cachedConfig = await ConfigCacheService.getCachedConfig();
      if (cachedConfig != null) {
        _config = cachedConfig;
      }
      
      notifyListeners();
    }
  }
  
  Future<void> refreshConfig() async {
    await loadConfig(forceRefresh: true);
  }
}

