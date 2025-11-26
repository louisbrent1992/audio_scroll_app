import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/spotlight_audiobook.dart';
import '../theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SpotlightWidget extends StatelessWidget {
  final SpotlightAudiobook spotlight;
  final VoidCallback onTap;
  
  const SpotlightWidget({
    super.key,
    required this.spotlight,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final snippet = spotlight.snippet;
    if (snippet == null) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accentColor,
                    AppTheme.primaryColor,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Row(
                children: [
                  // Book cover
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusM),
                      child: CachedNetworkImage(
                        imageUrl: snippet.coverImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.surfaceColor,
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.surfaceColor,
                          child: const Icon(Icons.book, color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: AppTheme.spacingL),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Badge
                        if (spotlight.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingM,
                              vertical: AppTheme.spacingXS,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.highlightColor,
                              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                            ),
                            child: Text(
                              spotlight.badge!,
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        
                        if (spotlight.badge != null)
                          const SizedBox(height: AppTheme.spacingS),
                        
                        // Title
                        Text(
                          snippet.bookTitle,
                          style: AppTheme.heading3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: AppTheme.spacingXS),
                        
                        // Author
                        Text(
                          snippet.author,
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        if (spotlight.promotionText.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacingS),
                          Text(
                            spotlight.promotionText,
                            style: AppTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Arrow icon
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0);
  }
}

