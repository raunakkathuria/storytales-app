import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:storytales/core/di/injection_container.dart';
import 'package:storytales/core/services/logging/logging_service.dart';
import 'package:storytales/core/theme/theme.dart';

/// Service for handling image loading, caching, and management.
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  // Get the logging service from the dependency injection container
  final _loggingService = sl<LoggingService>();

  // Custom cache manager with configured size and duration
  final cacheManager = CacheManager(
    Config(
      'storytales_images_cache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: 'storytales_image_cache_db'),
      fileService: HttpFileService(),
    ),
  );

  /// Default placeholder image path
  static const String placeholderImagePath = 'assets/images/stories/placeholder.jpg';

  /// Get image widget based on path type (network, file, or asset)
  Widget getImage({
    required String imagePath,
    required BoxFit fit,
    Widget Function(BuildContext, String)? placeholder,
    Widget Function(BuildContext, String, dynamic)? errorWidget,
  }) {
    defaultPlaceholder(context, url) => Container(
          color: StoryTalesTheme.primaryColor.withValues(alpha: 0.1),
          child: const Center(child: CircularProgressIndicator()),
        );

    defaultError(context, url, error) => Container(
          color: StoryTalesTheme.primaryColor.withValues(alpha: 0.3),
          child: const Center(
            child: Icon(
              Icons.image_not_supported,
              color: StoryTalesTheme.accentColor,
              size: 48,
            ),
          ),
        );

    // For local file paths, validate existence
    if (imagePath.startsWith('/')) {
      final file = File(imagePath);
      if (!file.existsSync()) {
        _loggingService.warning('Image file not found: $imagePath, using fallback');
        // Use fallback asset
        return Image.asset(
          placeholderImagePath,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              (errorWidget != null) ? errorWidget(context, imagePath, error) : defaultError(context, imagePath, error),
        );
      }

      // File exists, load it
      return Image.file(
        file,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            (errorWidget != null) ? errorWidget(context, imagePath, error) : defaultError(context, imagePath, error),
      );
    } else if (imagePath.startsWith('http')) {
      // Network image with caching
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: fit,
        cacheManager: cacheManager,
        placeholder: placeholder ?? defaultPlaceholder,
        errorWidget: errorWidget ?? defaultError,
      );
    } else {
      // Asset image
      return Image.asset(
        imagePath,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            (errorWidget != null) ? errorWidget(context, imagePath, error) : defaultError(context, imagePath, error),
      );
    }
  }

  /// Download and cache an image, returning the local file path
  Future<String> downloadAndCacheImage(String url, String fileName) async {
    try {
      // Use cache manager to download and cache
      final file = await cacheManager.getSingleFile(url);

      // If we need to store permanently (not just cache)
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final permanentPath = '${imagesDir.path}/$fileName';
      await file.copy(permanentPath);

      return permanentPath;
    } catch (e) {
      _loggingService.error('Failed to download and cache image: $e');
      // Return the placeholder image path
      return placeholderImagePath;
    }
  }

  /// Clear the cache
  Future<void> clearCache() async {
    await cacheManager.emptyCache();
  }

  /// Preload an image into memory cache
  Future<void> preloadImage(BuildContext context, String imagePath) async {
    if (imagePath.isEmpty) {
      return;
    }

    try {
      if (imagePath.startsWith('/')) {
        // Local file
        final file = File(imagePath);
        if (file.existsSync()) {
          await precacheImage(FileImage(file), context);
        } else {
          // Fallback to placeholder
          await precacheImage(const AssetImage(placeholderImagePath), context);
        }
      } else if (imagePath.startsWith('http')) {
        // Network image
        await cacheManager.getSingleFile(imagePath);
      } else {
        // Asset image
        await precacheImage(AssetImage(imagePath), context);
      }
    } catch (e) {
      _loggingService.warning('Failed to preload image: $imagePath, error: $e');
    }
  }
}
