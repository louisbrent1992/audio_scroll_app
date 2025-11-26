import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:device_info_plus/device_info_plus.dart';
import '../models/app_config.dart';
import '../models/banner.dart' as models;
import '../models/spotlight_audiobook.dart';

class ApiService {
  // Production URL - Update this with your actual production server URL
  static const String productionUrl =
      'https://audio-scroll-app-1010689391004.us-west2.run.app/api';

  // Development server port
  static const String devPort = '3000';

  // Singleton pattern for device info
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  static bool? _cachedIsPhysicalDevice;

  /// Check if running on a physical device (not emulator/simulator)
  /// This is cached after first check to avoid repeated async calls
  static Future<bool> _checkIsPhysicalDevice() async {
    if (_cachedIsPhysicalDevice != null) {
      return _cachedIsPhysicalDevice!;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        _cachedIsPhysicalDevice = androidInfo.isPhysicalDevice;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;

        // Check if it's a simulator using multiple methods
        // 1. Check environment variable (most reliable for iOS simulators)
        final hasSimulatorUdid = Platform.environment.containsKey(
          'SIMULATOR_UDID',
        );

        // 2. Check device name/model for simulator indicators
        final nameContainsSimulator = iosInfo.name.toLowerCase().contains(
          'simulator',
        );
        final modelContainsSimulator = iosInfo.model.toLowerCase().contains(
          'simulator',
        );

        // 3. Check utsname.machine for simulator architectures
        // Simulators can be: i386, x86_64 (Intel), or arm64 (Apple Silicon)
        // Physical devices have machine names like: iPhone15,2, iPhone16,1, etc.
        // Modern simulators on Apple Silicon use patterns like: iphone17,5, iphone16,2, etc.
        final machine = iosInfo.utsname.machine.toLowerCase();

        // Traditional simulator architectures
        final isTraditionalSimulatorArch =
            machine == 'i386' || machine == 'x86_64';

        // Modern Apple Silicon simulators: check if machine matches simulator pattern
        // Simulators often have patterns like "iphone17,5" (with comma) or are arm64
        // Physical devices typically have patterns like "iPhone15,2" (capital I, but we lowercase)
        final isModernSimulatorArch =
            machine == 'arm64' ||
            (machine.startsWith('iphone') && machine.contains(','));

        // 4. If we're in debug mode and it's not clearly a physical device,
        // assume it's a simulator (safer for development)
        final isDebugMode = kDebugMode;
        final isLikelySimulator =
            isDebugMode &&
            !hasSimulatorUdid &&
            !nameContainsSimulator &&
            !modelContainsSimulator &&
            (isModernSimulatorArch || machine == 'arm64');

        final isSimulator =
            hasSimulatorUdid ||
            nameContainsSimulator ||
            modelContainsSimulator ||
            isTraditionalSimulatorArch ||
            isModernSimulatorArch ||
            isLikelySimulator;

        _cachedIsPhysicalDevice = !isSimulator;

        if (kDebugMode) {
          print('🍎 iOS device check:');
          print('   name: ${iosInfo.name}');
          print('   model: ${iosInfo.model}');
          print('   machine: $machine');
          print('   hasSimulatorUdid: $hasSimulatorUdid');
          print('   isDebugMode: $isDebugMode');
          print('   isSimulator: $isSimulator');
          print('   isPhysicalDevice: $_cachedIsPhysicalDevice');
        }
      } else {
        // For web/desktop, assume it's a development environment
        _cachedIsPhysicalDevice = false;
      }
    } catch (e) {
      // Default to simulator/development if check fails (safer for development)
      // In production builds, this would be overridden by proper detection
      final defaultToPhysical = !kDebugMode;
      _cachedIsPhysicalDevice = defaultToPhysical;
      if (kDebugMode) {
        print(
          '⚠️ Device check failed, defaulting to: ${defaultToPhysical ? "physical" : "simulator"}',
        );
      }
    }

    final defaultValue = kDebugMode ? false : true;
    return _cachedIsPhysicalDevice ?? defaultValue;
  }

  /// Get base URL for API requests
  /// Uses development server for emulator/simulator, production server for physical devices
  static Future<String> get baseUrl async {
    final bool isPhysical = await _checkIsPhysicalDevice();

    if (isPhysical) {
      // Physical device - use production URL
      return productionUrl;
    } else {
      // Emulator/Simulator - use development server
      if (Platform.isAndroid) {
        // Android emulator uses 10.0.2.2 to access host machine's localhost
        return 'http://10.0.2.2:$devPort/api';
      } else if (Platform.isIOS) {
        // iOS simulator can use localhost directly
        return 'http://localhost:$devPort/api';
      } else {
        // Web/Desktop - use localhost
        return 'http://localhost:$devPort/api';
      }
    }
  }

  /// Make HTTP GET request with error handling
  static Future<http.Response> _get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final url = await baseUrl;
      final uri = Uri.parse(
        '$url/$endpoint',
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timed out');
            },
          );

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('API Error (GET $endpoint): $e');
      }
      rethrow;
    }
  }

  // Get app configuration
  static Future<AppConfig> getAppConfig() async {
    try {
      final response = await _get('config');

      if (response.statusCode == 200) {
        return AppConfig.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw Exception('Failed to load app config: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch app config, using defaults: $e');
      }
      // Return default config if API fails
      return AppConfig(
        id: 'default',
        version: 1,
        theme: ThemeConfig.fromJson({}),
        features: FeaturesConfig.fromJson({}),
        updatedAt: DateTime.now(),
        createdAt: DateTime.now(),
      );
    }
  }

  // Get active banners
  static Future<List<models.Banner>> getActiveBanners({
    String platform = 'all',
    String targetAudience = 'all',
  }) async {
    try {
      final response = await _get(
        'banners',
        queryParams: {'platform': platform, 'targetAudience': targetAudience},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        return data
            .map((json) => models.Banner.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch banners: $e');
      }
      return [];
    }
  }

  // Get active spotlight audiobooks
  static Future<List<SpotlightAudiobook>> getActiveSpotlights({
    String platform = 'all',
    String targetAudience = 'all',
  }) async {
    try {
      final response = await _get(
        'spotlight',
        queryParams: {'platform': platform, 'targetAudience': targetAudience},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body) as List<dynamic>;
        return data
            .map(
              (json) =>
                  SpotlightAudiobook.fromJson(json as Map<String, dynamic>),
            )
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch spotlights: $e');
      }
      return [];
    }
  }
}
