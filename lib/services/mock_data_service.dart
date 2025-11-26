import '../models/audiobook_snippet.dart';

class MockDataService {
  static List<AudiobookSnippet> getMockSnippets() {
    return [
      AudiobookSnippet(
        id: '1',
        bookTitle: 'The Seven Husbands of Evelyn Hugo',
        author: 'Taylor Jenkins Reid',
        narrator: 'Julia Whelan',
        genre: 'Historical Fiction',
        coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1616693024i/32620332.jpg',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        durationSeconds: 60,
        startTimeSeconds: 120,
        captions: _generateMockCaptions('The Seven Husbands of Evelyn Hugo is a captivating tale of ambition, love, and the price of fame.'),
        purchaseUrl: 'https://www.audible.com',
        description: 'A captivating tale of ambition, love, and the price of fame.',
        averageRating: 4.5,
        totalRatings: 125000,
      ),
      AudiobookSnippet(
        id: '2',
        bookTitle: 'Project Hail Mary',
        author: 'Andy Weir',
        narrator: 'Ray Porter',
        genre: 'Science Fiction',
        coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1597695864i/54493401.jpg',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        durationSeconds: 75,
        startTimeSeconds: 300,
        captions: _generateMockCaptions('Ryland Grace is the sole survivor on a desperate, last-chance mission.'),
        purchaseUrl: 'https://www.audible.com',
        description: 'A lone astronaut must save the earth from disaster.',
        averageRating: 4.8,
        totalRatings: 89000,
      ),
      AudiobookSnippet(
        id: '3',
        bookTitle: 'The Silent Patient',
        author: 'Alex Michaelides',
        narrator: 'Jack Hawkins',
        genre: 'Thriller',
        coverImageUrl: 'https://images-na.ssl-images-amazon.com/images/S/compressed.photo.goodreads.com/books/1587826894i/40097951.jpg',
        audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
        durationSeconds: 90,
        startTimeSeconds: 450,
        captions: _generateMockCaptions('Alicia Berenson\'s life is seemingly perfect until she shoots her husband five times.'),
        purchaseUrl: 'https://www.audible.com',
        description: 'A psychological thriller about a woman who refuses to speak.',
        averageRating: 4.2,
        totalRatings: 156000,
      ),
    ];
  }
  
  static List<CaptionWord> _generateMockCaptions(String text) {
    final words = text.split(' ');
    final List<CaptionWord> captions = [];
    double currentTime = 0.0;
    const double wordDuration = 0.5; // Average 0.5 seconds per word
    
    for (final word in words) {
      captions.add(CaptionWord(
        word: word,
        startTime: currentTime,
        endTime: currentTime + wordDuration,
      ));
      currentTime += wordDuration;
    }
    
    return captions;
  }
}

