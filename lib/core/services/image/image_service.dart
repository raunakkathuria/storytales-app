import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:storytales/core/theme/theme.dart';

/// Simplified image service for API-driven image loading.
/// The API provides final, optimized image URLs with proper caching headers.
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  /// Get image widget for network URLs provided by the API.
  /// The API handles all image optimization, CDN delivery, and caching headers.
  Widget getImage({
    required String imageUrl,
    required BoxFit fit,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
  }) {
    // Default loading placeholder
    Widget defaultPlaceholder(BuildContext context, String url) {
      return Container(
        color: StoryTalesTheme.primaryColor.withValues(alpha: 0.1),
        child: const Center(
          child: CircularProgressIndicator(
            color: StoryTalesTheme.primaryColor,
          ),
        ),
      );
    }

    // Default error widget
    Widget defaultError(BuildContext context, String url, dynamic error) {
      return Container(
        color: StoryTalesTheme.primaryColor.withValues(alpha: 0.3),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            color: StoryTalesTheme.accentColor,
            size: 48,
          ),
        ),
      );
    }

    // Handle empty or invalid URLs
    if (imageUrl.isEmpty) {
      return Builder(
        builder: (context) => (errorWidget != null)
            ? errorWidget(context, imageUrl, 'Empty image URL')
            : defaultError(context, imageUrl, 'Empty image URL'),
      );
    }

    // Use cached network image for all API-provided URLs
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: fit,
      placeholder: placeholder ?? defaultPlaceholder,
      errorWidget: errorWidget ?? defaultError,
      // Use default caching - no custom configuration needed
      // The API provides proper cache headers for optimal caching
    );
  }

  /// Preload an image into cache for better user experience.
  /// Only works with network URLs provided by the API.
  Future<void> preloadImage(BuildContext context, String imageUrl) async {
    if (imageUrl.isEmpty || !imageUrl.startsWith('http')) {
      return;
    }

    try {
      // Use cached network image's preloading
      await precacheImage(
        CachedNetworkImageProvider(imageUrl),
        context,
      );
    } catch (e) {
      // Silently fail - preloading is optional for performance
      // The image will still load when displayed
    }
  }
}
