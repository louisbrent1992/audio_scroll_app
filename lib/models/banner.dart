class Banner {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String actionUrl;
  final String actionText;
  final int priority;
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  final String targetAudience;
  final String platform;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Banner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.actionUrl,
    required this.actionText,
    required this.priority,
    required this.isActive,
    required this.startDate,
    this.endDate,
    required this.targetAudience,
    required this.platform,
    required this.createdAt,
    required this.updatedAt,
  });
  
  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      imageUrl: json['imageUrl'] as String,
      actionUrl: json['actionUrl'] as String? ?? '',
      actionText: json['actionText'] as String? ?? 'Learn More',
      priority: json['priority'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'].toString())
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'].toString())
          : null,
      targetAudience: json['targetAudience'] as String? ?? 'all',
      platform: json['platform'] as String? ?? 'all',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
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

