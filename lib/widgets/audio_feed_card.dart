import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:just_audio/just_audio.dart';
import '../models/audiobook_snippet.dart';
import '../theme/app_theme.dart';
import '../services/audio_player_service.dart';
import 'karaoke_captions.dart';
import 'dart:async';

class AudioFeedCard extends StatefulWidget {
  final AudiobookSnippet snippet;
  final AudioPlayerService audioPlayer;
  final VoidCallback onSwipeUp;
  final VoidCallback onSwipeDown;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final VoidCallback onGetBook;
  final VoidCallback? onAuthorPage;
  
  const AudioFeedCard({
    super.key,
    required this.snippet,
    required this.audioPlayer,
    required this.onSwipeUp,
    required this.onSwipeDown,
    required this.onLike,
    required this.onBookmark,
    required this.onShare,
    required this.onGetBook,
    this.onAuthorPage,
  });
  
  @override
  State<AudioFeedCard> createState() => _AudioFeedCardState();
}

class _AudioFeedCardState extends State<AudioFeedCard> {
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  int _highlightedWordIndex = -1;
  
  @override
  void initState() {
    super.initState();
    _initializeAudio();
    _setupListeners();
  }
  
  Future<void> _initializeAudio() async {
    try {
      await widget.audioPlayer.loadAudio(widget.snippet.audioUrl);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load audio: $e')),
        );
      }
    }
  }
  
  void _setupListeners() {
    widget.audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _updateHighlightedWord(position);
        });
      }
    });
    
    widget.audioPlayer.durationStream.listen((duration) {
      // Duration available if needed
    });
    
    widget.audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state.playing);
        if (!state.playing && state.processingState == ProcessingState.completed) {
          // Auto-advance to next when finished
          widget.onSwipeUp();
        }
      }
    });
  }
  
  void _updateHighlightedWord(Duration position) {
    final positionSeconds = position.inMilliseconds / 1000.0;
    for (int i = 0; i < widget.snippet.captions.length; i++) {
      final caption = widget.snippet.captions[i];
      if (positionSeconds >= caption.startTime && positionSeconds < caption.endTime) {
        if (_highlightedWordIndex != i) {
          setState(() => _highlightedWordIndex = i);
        }
        break;
      }
    }
  }
  
  void _togglePlayPause() {
    if (_isPlaying) {
      widget.audioPlayer.pause();
    } else {
      widget.audioPlayer.play();
    }
  }
  
  void _handleLongPress() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusL)),
      ),
      builder: (context) => _buildSpeedControls(),
    );
  }
  
  Widget _buildSpeedControls() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Playback Speed', style: AppTheme.heading3),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSpeedButton('1.0x', 1.0),
              _buildSpeedButton('1.25x', 1.25),
              _buildSpeedButton('1.5x', 1.5),
              _buildSpeedButton('2.0x', 2.0),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSpeedButton(String label, double speed) {
    final isSelected = widget.audioPlayer.playbackSpeed == speed;
    return ElevatedButton(
      onPressed: () {
        widget.audioPlayer.setSpeed(speed);
        Navigator.pop(context);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppTheme.highlightColor : AppTheme.surfaceColor,
      ),
      child: Text(label),
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      onLongPress: _handleLongPress,
      onDoubleTap: widget.onLike,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred background image
          _buildBackground(),
          
          // Content overlay
          _buildContent(),
          
          // Right side action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }
  
  Widget _buildBackground() {
    return CachedNetworkImage(
      imageUrl: widget.snippet.coverImageUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: AppTheme.surfaceColor,
        child: const Center(child: CircularProgressIndicator()),
      ),
      errorWidget: (context, url, error) => Container(
        color: AppTheme.surfaceColor,
        child: const Icon(Icons.error, color: AppTheme.textSecondary),
      ),
    )
        .animate()
        .blur(begin: const Offset(0, 0), end: const Offset(10, 10))
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1));
  }
  
  Widget _buildContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.9),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            
            // Book cover or waveform (center)
            _buildCenterVisual(),
            
            const SizedBox(height: AppTheme.spacingL),
            
            // Karaoke captions
            KaraokeCaptions(
              captions: widget.snippet.captions,
              currentPosition: _currentPosition,
              highlightedWordIndex: _highlightedWordIndex,
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // Book info (bottom)
            _buildBookInfo(),
            
            const SizedBox(height: AppTheme.spacingL),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCenterVisual() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: CachedNetworkImage(
          imageUrl: widget.snippet.coverImageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: AppTheme.surfaceColor,
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    )
        .animate(target: _isPlaying ? 1 : 0)
        .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05))
        .then()
        .scale(begin: const Offset(1.05, 1.05), end: const Offset(1, 1));
  }
  
  Widget _buildBookInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Genre tag
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: AppTheme.highlightColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              border: Border.all(color: AppTheme.highlightColor, width: 1),
            ),
            child: Text(
              '#${widget.snippet.genre}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.highlightColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingS),
          
          // Title
          Text(
            widget.snippet.bookTitle,
            style: AppTheme.heading2,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: AppTheme.spacingXS),
          
          // Author
          Text(
            widget.snippet.author,
            style: AppTheme.bodyLarge.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          
          const SizedBox(height: AppTheme.spacingXS),
          
          // Narrator
          Row(
            children: [
              const Icon(Icons.mic, size: 16, color: AppTheme.textTertiary),
              const SizedBox(width: AppTheme.spacingXS),
              Text(
                'Narrated by ${widget.snippet.narrator}',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons() {
    return Positioned(
      right: AppTheme.spacingM,
      top: 0,
      bottom: 0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildActionButton(
            icon: Icons.person,
            onTap: widget.onAuthorPage ?? () {},
            tooltip: 'Author Page',
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildActionButton(
            icon: Icons.bookmark_border,
            onTap: widget.onBookmark,
            tooltip: 'Save to Library',
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildActionButton(
            icon: Icons.share,
            onTap: widget.onShare,
            tooltip: 'Share',
          ),
          const SizedBox(height: AppTheme.spacingM),
          _buildActionButton(
            icon: Icons.shopping_cart,
            onTap: widget.onGetBook,
            tooltip: 'Get Book',
            isPrimary: true,
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isPrimary
                ? AppTheme.highlightColor
                : Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: AppTheme.textPrimary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

