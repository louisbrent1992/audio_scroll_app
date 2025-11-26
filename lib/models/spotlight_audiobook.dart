import 'audiobook_snippet.dart';

class SpotlightAudiobook {
  final String id;
  final String audiobookSnippetId;
  final String title;
  final int priority;
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  final String promotionText;
  final String? badge;
  final String targetAudience;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AudiobookSnippet? snippet;
  
  SpotlightAudiobook({
    required this.id,
    required this.audiobookSnippetId,
    required this.title,
    required this.priority,
    required this.isActive,
    required this.startDate,
    this.endDate,
    required this.promotionText,
    this.badge,
    required this.targetAudience,
    required this.createdAt,
    required this.updatedAt,
    this.snippet,
  });
  
  factory SpotlightAudiobook.fromJson(Map<String, dynamic> json) {
    return SpotlightAudiobook(
      id: json['id'] as String,
      audiobookSnippetId: json['audiobookSnippetId'] as String,
      title: json['title'] as String? ?? '',
      priority: json['priority'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'].toString())
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'].toString())
          : null,
      promotionText: json['promotionText'] as String? ?? '',
      badge: json['badge'] as String?,
      targetAudience: json['targetAudience'] as String? ?? 'all',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
      snippet: json['snippet'] != null
          ? AudiobookSnippet.fromJson(json['snippet'] as Map<String, dynamic>)
          : null,
    );
  }
  
  bool isCurrentlyActive() {
    if (!isActive) return false;
    final now = DateTime.now();
    if (now.isBefore(startDate)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    return true;
  }
}

