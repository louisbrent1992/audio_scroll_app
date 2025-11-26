import 'package:flutter/material.dart';

class AppConfig {
  final String id;
  final int version;
  final ThemeConfig theme;
  final FeaturesConfig features;
  final DateTime updatedAt;
  final DateTime createdAt;
  
  AppConfig({
    required this.id,
    required this.version,
    required this.theme,
    required this.features,
    required this.updatedAt,
    required this.createdAt,
  });
  
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      id: json['id'] as String? ?? 'default',
      version: json['version'] as int? ?? 1,
      theme: ThemeConfig.fromJson(json['theme'] as Map<String, dynamic>? ?? {}),
      features: FeaturesConfig.fromJson(json['features'] as Map<String, dynamic>? ?? {}),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'version': version,
      'theme': theme.toJson(),
      'features': features.toJson(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ThemeConfig {
  final String primaryColor;
  final String secondaryColor;
  final String accentColor;
  final String highlightColor;
  final String surfaceColor;
  final String backgroundColor;
  final String textPrimary;
  final String textSecondary;
  final String textTertiary;
  
  ThemeConfig({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.highlightColor,
    required this.surfaceColor,
    required this.backgroundColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });
  
  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      primaryColor: json['primaryColor'] as String? ?? '#1A1A2E',
      secondaryColor: json['secondaryColor'] as String? ?? '#16213E',
      accentColor: json['accentColor'] as String? ?? '#0F3460',
      highlightColor: json['highlightColor'] as String? ?? '#E94560',
      surfaceColor: json['surfaceColor'] as String? ?? '#0F0F1E',
      backgroundColor: json['backgroundColor'] as String? ?? '#000000',
      textPrimary: json['textPrimary'] as String? ?? '#FFFFFF',
      textSecondary: json['textSecondary'] as String? ?? '#B0B0B0',
      textTertiary: json['textTertiary'] as String? ?? '#808080',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'primaryColor': primaryColor,
      'secondaryColor': secondaryColor,
      'accentColor': accentColor,
      'highlightColor': highlightColor,
      'surfaceColor': surfaceColor,
      'backgroundColor': backgroundColor,
      'textPrimary': textPrimary,
      'textSecondary': textSecondary,
      'textTertiary': textTertiary,
    };
  }
  
  Color get primaryColorValue => _hexToColor(primaryColor);
  Color get secondaryColorValue => _hexToColor(secondaryColor);
  Color get accentColorValue => _hexToColor(accentColor);
  Color get highlightColorValue => _hexToColor(highlightColor);
  Color get surfaceColorValue => _hexToColor(surfaceColor);
  Color get backgroundColorValue => _hexToColor(backgroundColor);
  Color get textPrimaryValue => _hexToColor(textPrimary);
  Color get textSecondaryValue => _hexToColor(textSecondary);
  Color get textTertiaryValue => _hexToColor(textTertiary);
  
  Color _hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}

class FeaturesConfig {
  final bool enableBanners;
  final bool enableSpotlight;
  final bool enableOnboarding;
  final int maxSnippetDuration;
  final int minSnippetDuration;
  
  FeaturesConfig({
    required this.enableBanners,
    required this.enableSpotlight,
    required this.enableOnboarding,
    required this.maxSnippetDuration,
    required this.minSnippetDuration,
  });
  
  factory FeaturesConfig.fromJson(Map<String, dynamic> json) {
    return FeaturesConfig(
      enableBanners: json['enableBanners'] as bool? ?? true,
      enableSpotlight: json['enableSpotlight'] as bool? ?? true,
      enableOnboarding: json['enableOnboarding'] as bool? ?? true,
      maxSnippetDuration: json['maxSnippetDuration'] as int? ?? 90,
      minSnippetDuration: json['minSnippetDuration'] as int? ?? 30,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'enableBanners': enableBanners,
      'enableSpotlight': enableSpotlight,
      'enableOnboarding': enableOnboarding,
      'maxSnippetDuration': maxSnippetDuration,
      'minSnippetDuration': minSnippetDuration,
    };
  }
}

