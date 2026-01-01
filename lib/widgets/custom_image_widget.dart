import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomImageWidget extends StatelessWidget {
  final String? imageUrl;
  final double width;
  final double height;
  final BoxFit fit;

  /// Optional widget to show when the image fails to load.
  /// If null, a default asset image is shown.
  final Widget? errorWidget;

  const CustomImageWidget({
    super.key,
    required this.imageUrl,
    this.width = 60,
    this.height = 60,
    this.fit = BoxFit.cover,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final urlToLog = imageUrl == null ? 'null' : (imageUrl!.length > 50 ? '${imageUrl!.substring(0, 50)}...' : imageUrl!);
    // Loading image
    return CachedNetworkImage(
      imageUrl: imageUrl ??
          'https://images.unsplash.com/photo-1568702846914-96b305d2aaeb?=80&w=2940&auto=format&fit=crop',
      width: width,
      height: height,
      fit: fit,
      cacheManager: DefaultCacheManager(), // Add cache manager to prevent rebuilding

      // Use caller-supplied widget if provided, else fallback to grey container.
      errorWidget: (context, url, error) =>
          errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: Icon(
              Icons.person,
              size: width * 0.6,
              color: Colors.grey[600],
            ),
          ),

      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
      ),
    );
  }
}
