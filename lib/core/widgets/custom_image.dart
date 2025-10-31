import 'dart:io';
import 'package:flutter/material.dart';

/// Custom widget that automatically detects and displays images from different sources
class CustomImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;
  final Widget? loadingWidget;
  final Color? backgroundColor;

  const CustomImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
    this.loadingWidget,
    this.backgroundColor,
  });

  /// Determines the type of image source
  ImageSourceType _getImageSourceType() {
    if (imagePath.isEmpty) {
      return ImageSourceType.none;
    }

    // Check if it's a network URL
    if (imagePath.startsWith('http://') || 
        imagePath.startsWith('https://') ||
        imagePath.startsWith('www.')) {
      return ImageSourceType.network;
    }

    // Check if it's an asset
    if (imagePath.startsWith('assets/') || 
        imagePath.startsWith('images/') ||
        imagePath.contains('assets')) {
      return ImageSourceType.asset;
    }

    // Otherwise, treat it as a file path
    return ImageSourceType.file;
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: backgroundColor ?? Colors.grey[300],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, color: Colors.grey[600], size: 40),
              const SizedBox(height: 8),
              Text(
                'Image not found',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        );
  }

  Widget _buildLoadingWidget() {
    return loadingWidget ??
        Container(
          width: width,
          height: height,
          color: backgroundColor ?? Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
  }

  Widget _buildImage(Widget imageWidget) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }
    return imageWidget;
  }

  @override
  Widget build(BuildContext context) {
    final sourceType = _getImageSourceType();

    switch (sourceType) {
      case ImageSourceType.network:
        return _buildImage(
          Image.network(
            imagePath,
            width: width,
            height: height,
            fit: fit,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildLoadingWidget();
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget();
            },
          ),
        );

      case ImageSourceType.asset:
        return _buildImage(
          Image.asset(
            imagePath,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget();
            },
          ),
        );

      case ImageSourceType.file:
        final file = File(imagePath);
        if (!file.existsSync()) {
          return _buildErrorWidget();
        }
        return _buildImage(
          Image.file(
            file,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (context, error, stackTrace) {
              return _buildErrorWidget();
            },
          ),
        );

      case ImageSourceType.none:
        return _buildErrorWidget();
    }
  }
}

/// Enum to represent different image source types
enum ImageSourceType {
  network,
  asset,
  file,
  none,
}

/// Extension method for easy image display
extension ImagePathExtension on String {
  /// Returns a CustomImage widget for this path
  Widget toImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? errorWidget,
    Widget? loadingWidget,
    Color? backgroundColor,
  }) {
    return CustomImage(
      imagePath: this,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      errorWidget: errorWidget,
      loadingWidget: loadingWidget,
      backgroundColor: backgroundColor,
    );
  }
}

