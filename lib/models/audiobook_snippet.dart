class AudiobookSnippet {
  final String id;
  final String bookTitle;
  final String author;
  final String narrator;
  final String genre;
  final String coverImageUrl;
  final String audioUrl;
  final int durationSeconds; // Duration of the snippet (30-90 seconds)
  final int startTimeSeconds; // Start time in the full audiobook
  final List<CaptionWord> captions; // Karaoke-style captions with timestamps
  final String purchaseUrl; // Deep link to purchase
  final String? authorPageUrl;
  final String description;
  final double? averageRating;
  final int? totalRatings;
  
  AudiobookSnippet({
    required this.id,
    required this.bookTitle,
    required this.author,
    required this.narrator,
    required this.genre,
    required this.coverImageUrl,
    required this.audioUrl,
    required this.durationSeconds,
    required this.startTimeSeconds,
    required this.captions,
    required this.purchaseUrl,
    this.authorPageUrl,
    this.description = '',
    this.averageRating,
    this.totalRatings,
  });
  
  // Factory constructor for creating from JSON
  factory AudiobookSnippet.fromJson(Map<String, dynamic> json) {
    return AudiobookSnippet(
      id: json['id'] as String,
      bookTitle: json['bookTitle'] as String,
      author: json['author'] as String,
      narrator: json['narrator'] as String,
      genre: json['genre'] as String,
      coverImageUrl: json['coverImageUrl'] as String,
      audioUrl: json['audioUrl'] as String,
      durationSeconds: json['durationSeconds'] as int,
      startTimeSeconds: json['startTimeSeconds'] as int,
      captions: (json['captions'] as List<dynamic>)
          .map((c) => CaptionWord.fromJson(c as Map<String, dynamic>))
          .toList(),
      purchaseUrl: json['purchaseUrl'] as String,
      authorPageUrl: json['authorPageUrl'] as String?,
      description: json['description'] as String? ?? '',
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      totalRatings: json['totalRatings'] as int?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookTitle': bookTitle,
      'author': author,
      'narrator': narrator,
      'genre': genre,
      'coverImageUrl': coverImageUrl,
      'audioUrl': audioUrl,
      'durationSeconds': durationSeconds,
      'startTimeSeconds': startTimeSeconds,
      'captions': captions.map((c) => c.toJson()).toList(),
      'purchaseUrl': purchaseUrl,
      'authorPageUrl': authorPageUrl,
      'description': description,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
    };
  }
}

class CaptionWord {
  final String word;
  final double startTime; // Start time in seconds
  final double endTime; // End time in seconds
  
  CaptionWord({
    required this.word,
    required this.startTime,
    required this.endTime,
  });
  
  factory CaptionWord.fromJson(Map<String, dynamic> json) {
    return CaptionWord(
      word: json['word'] as String,
      startTime: (json['startTime'] as num).toDouble(),
      endTime: (json['endTime'] as num).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}

