import 'package:flutter/material.dart';
import '../models/audiobook_snippet.dart';
import '../theme/app_theme.dart';

class KaraokeCaptions extends StatelessWidget {
  final List<CaptionWord> captions;
  final Duration currentPosition;
  final int highlightedWordIndex;
  
  const KaraokeCaptions({
    super.key,
    required this.captions,
    required this.currentPosition,
    required this.highlightedWordIndex,
  });
  
  @override
  Widget build(BuildContext context) {
    if (captions.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingM,
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: AppTheme.spacingS,
        runSpacing: AppTheme.spacingS,
        children: List.generate(
          captions.length,
          (index) => _buildWord(
            captions[index].word,
            index == highlightedWordIndex,
          ),
        ),
      ),
    );
  }
  
  Widget _buildWord(String word, bool isHighlighted) {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: isHighlighted
          ? AppTheme.karaokeTextHighlight
          : AppTheme.karaokeText,
      child: Text(word),
    );
  }
}

