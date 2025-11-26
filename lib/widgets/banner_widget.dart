import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/banner.dart' as models;
import '../theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class BannerWidget extends StatelessWidget {
  final models.Banner banner;
  final VoidCallback? onDismiss;
  
  const BannerWidget({
    super.key,
    required this.banner,
    this.onDismiss,
  });
  
  Future<void> _handleTap() async {
    if (banner.actionUrl.isNotEmpty) {
      final uri = Uri.parse(banner.actionUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Stack(
          children: [
            // Background image
            CachedNetworkImage(
              imageUrl: banner.imageUrl,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                height: 150,
                color: AppTheme.surfaceColor,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 150,
                color: AppTheme.surfaceColor,
                child: const Icon(Icons.error, color: AppTheme.textSecondary),
              ),
            ),
            
            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleTap,
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (banner.title.isNotEmpty)
                          Text(
                            banner.title,
                            style: AppTheme.heading3.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (banner.subtitle.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacingXS),
                          Text(
                            banner.subtitle,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (banner.actionUrl.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.spacingM),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingM,
                              vertical: AppTheme.spacingS,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.highlightColor,
                              borderRadius: BorderRadius.circular(AppTheme.radiusS),
                            ),
                            child: Text(
                              banner.actionText,
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Dismiss button
            if (onDismiss != null)
              Positioned(
                top: AppTheme.spacingS,
                right: AppTheme.spacingS,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textPrimary),
                  onPressed: onDismiss,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    padding: const EdgeInsets.all(AppTheme.spacingXS),
                  ),
                ),
              ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: -0.1, end: 0);
  }
}

