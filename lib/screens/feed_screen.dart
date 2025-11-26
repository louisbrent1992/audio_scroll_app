import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/audiobook_snippet.dart';
import '../models/banner.dart' as models;
import '../models/spotlight_audiobook.dart';
import '../services/audio_player_service.dart';
import '../services/mock_data_service.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../providers/app_config_provider.dart';
import '../widgets/audio_feed_card.dart';
import '../widgets/banner_widget.dart';
import '../widgets/spotlight_widget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

enum FeedItemType { banner, spotlight, snippet }

class FeedItem {
  final FeedItemType type;
  final dynamic data;
  
  FeedItem({required this.type, required this.data});
}

class _FeedScreenState extends State<FeedScreen> {
  final PageController _pageController = PageController();
  final AudioPlayerService _audioPlayer = AudioPlayerService();
  List<FeedItem> _feedItems = [];
  List<AudiobookSnippet> _snippets = [];
  List<models.Banner> _banners = [];
  List<SpotlightAudiobook> _spotlights = [];
  int _currentIndex = 0;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _loadFeed();
  }
  
  Future<void> _loadFeed() async {
    final configProvider = Provider.of<AppConfigProvider>(context, listen: false);
    
    // Load snippets
    final snippets = MockDataService.getMockSnippets();
    
    // Load banners and spotlights if enabled
    if (configProvider.enableBanners) {
      try {
        final platform = Platform.isIOS ? 'ios' : 'android';
        _banners = await ApiService.getActiveBanners(platform: platform);
      } catch (e) {
        // Ignore errors, use empty list
      }
    }
    
    if (configProvider.enableSpotlight) {
      try {
        final platform = Platform.isIOS ? 'ios' : 'android';
        _spotlights = await ApiService.getActiveSpotlights(platform: platform);
      } catch (e) {
        // Ignore errors, use empty list
      }
    }
    
    // Build feed items: banners first, then spotlights, then snippets
    final List<FeedItem> feedItems = [];
    
    // Add banners
    for (final banner in _banners) {
      if (banner.isCurrentlyActive()) {
        feedItems.add(FeedItem(type: FeedItemType.banner, data: banner));
      }
    }
    
    // Add spotlights
    for (final spotlight in _spotlights) {
      if (spotlight.isCurrentlyActive() && spotlight.snippet != null) {
        feedItems.add(FeedItem(type: FeedItemType.spotlight, data: spotlight));
      }
    }
    
    // Add snippets
    for (final snippet in snippets) {
      feedItems.add(FeedItem(type: FeedItemType.snippet, data: snippet));
    }
    
    setState(() {
      _snippets = snippets;
      _feedItems = feedItems;
      _isInitialized = true;
    });
    
    // Load first snippet if available
    final firstSnippetIndex = _feedItems.indexWhere((item) => item.type == FeedItemType.snippet);
    if (firstSnippetIndex >= 0) {
      _currentIndex = firstSnippetIndex;
      await _loadCurrentSnippet();
    }
  }
  
  Future<void> _loadCurrentSnippet() async {
    if (_currentIndex >= _feedItems.length) return;
    
    final item = _feedItems[_currentIndex];
    if (item.type != FeedItemType.snippet) return;
    
    final snippet = item.data as AudiobookSnippet;
    try {
      await _audioPlayer.stop();
      await _audioPlayer.loadAudio(snippet.audioUrl);
      await _audioPlayer.play();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load audio: $e')),
        );
      }
    }
  }
  
  void _onSwipeUp() {
    if (_currentIndex < _feedItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _onSwipeDown() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Only load audio if it's a snippet
    final item = _feedItems[index];
    if (item.type == FeedItemType.snippet) {
      _loadCurrentSnippet();
    } else {
      // Pause audio when viewing banners or spotlights
      _audioPlayer.pause();
    }
  }
  
  void _onLike() {
    // Add to wishlist
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to Wishlist'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  void _onBookmark() {
    // Save to library
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Saved to Library'),
        duration: Duration(seconds: 1),
      ),
    );
  }
  
  Future<void> _onShare() async {
    final snippet = _snippets[_currentIndex];
    final text = 'Check out "${snippet.bookTitle}" by ${snippet.author} on AudioScroll!';
    await Share.share(text);
  }
  
  Future<void> _onGetBook() async {
    final item = _feedItems[_currentIndex];
    if (item.type != FeedItemType.snippet) return;
    
    final snippet = item.data as AudiobookSnippet;
    final uri = Uri.parse(snippet.purchaseUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open purchase link')),
        );
      }
    }
  }
  
  Future<void> _onAuthorPage() async {
    final item = _feedItems[_currentIndex];
    if (item.type != FeedItemType.snippet) return;
    
    final snippet = item.data as AudiobookSnippet;
    if (snippet.authorPageUrl != null) {
      final uri = Uri.parse(snippet.authorPageUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
  
  void _onSpotlightTap(SpotlightAudiobook spotlight) {
    // Find the spotlight in feed and navigate to it, or navigate to its snippet
    final index = _feedItems.indexWhere(
      (item) => item.type == FeedItemType.snippet && 
                 (item.data as AudiobookSnippet).id == spotlight.audiobookSnippetId,
    );
    
    if (index >= 0) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (_feedItems.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Text(
            'No content available',
            style: AppTheme.bodyLarge,
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        onPageChanged: _onPageChanged,
        itemCount: _feedItems.length,
        itemBuilder: (context, index) {
          final item = _feedItems[index];
          
          switch (item.type) {
            case FeedItemType.banner:
              return BannerWidget(
                banner: item.data as models.Banner,
                onDismiss: () {
                  // Optionally remove banner from feed
                },
              );
            
            case FeedItemType.spotlight:
              return SpotlightWidget(
                spotlight: item.data as SpotlightAudiobook,
                onTap: () => _onSpotlightTap(item.data as SpotlightAudiobook),
              );
            
            case FeedItemType.snippet:
              final snippet = item.data as AudiobookSnippet;
              return AudioFeedCard(
                snippet: snippet,
                audioPlayer: _audioPlayer,
                onSwipeUp: _onSwipeUp,
                onSwipeDown: _onSwipeDown,
                onLike: _onLike,
                onBookmark: _onBookmark,
                onShare: _onShare,
                onGetBook: _onGetBook,
                onAuthorPage: _onAuthorPage,
              );
          }
        },
      ),
    );
  }
}

