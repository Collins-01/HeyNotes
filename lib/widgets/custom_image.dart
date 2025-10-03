import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' hide Cache;
import 'package:cached_network_image/cached_network_image.dart';

class CustomImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? color;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BlendMode? colorBlendMode;
  final double? opacity;

  const CustomImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.borderRadius,
    this.color,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.padding,
    this.margin,
    this.colorBlendMode,
    this.opacity,
  });

  static CustomImage circular({
    required String imagePath,
    required double size,
    Color? color,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    Color? backgroundColor,
    double? opacity,
  }) {
    return CustomImage(
      imagePath: imagePath,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      color: color,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      backgroundColor: backgroundColor,
      opacity: opacity,
    );
  }

  // Create rounded rectangle image
  static CustomImage rounded({
    required String imagePath,
    double? width,
    double? height,
    double borderRadius = 8.0,
    Color? color,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    Color? backgroundColor,
    double? opacity,
  }) {
    return CustomImage(
      imagePath: imagePath,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(borderRadius),
      color: color,
      fit: fit,
      placeholder: placeholder,
      errorWidget: errorWidget,
      backgroundColor: backgroundColor,
      opacity: opacity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      ),
      clipBehavior: borderRadius != null ? Clip.antiAlias : Clip.none,
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    final imageWidget = _getImageWidget();

    if (opacity != null && opacity! < 1.0) {
      return Opacity(opacity: opacity!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _getImageWidget() {
    // Determine image type based on path
    if (_isNetworkUrl(imagePath)) {
      if (_isSvg(imagePath)) {
        return _buildNetworkSvg();
      } else {
        return _buildNetworkImage();
      }
    } else if (_isAsset(imagePath)) {
      if (_isSvg(imagePath)) {
        return _buildAssetSvg();
      } else {
        return _buildAssetImage();
      }
    } else {
      // File path
      if (_isSvg(imagePath)) {
        return _buildFileSvg();
      } else {
        return _buildFileImage();
      }
    }
  }

  // Network Image (with caching)
  Widget _buildNetworkImage() {
    return CachedNetworkImage(
      imageUrl: imagePath,
      width: width,
      height: height,
      fit: fit,
      color: color,
      // httpHeaders: {'Authorization': 'Bearer $token'},
      colorBlendMode: colorBlendMode,
      placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
      errorWidget: (context, url, error) =>
          errorWidget ?? _defaultErrorWidget(),
    );
  }

  // Network SVG
  Widget _buildNetworkSvg() {
    return SvgPicture.network(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color!, colorBlendMode ?? BlendMode.srcIn)
          : null,
      placeholderBuilder: (context) => placeholder ?? _defaultPlaceholder(),
    );
  }

  // Asset Image
  Widget _buildAssetImage() {
    return Image.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _defaultErrorWidget(),
    );
  }

  // Asset SVG
  Widget _buildAssetSvg() {
    return SvgPicture.asset(
      imagePath,
      width: width,
      height: height,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color!, colorBlendMode ?? BlendMode.srcIn)
          : null,
    );
  }

  // File Image
  Widget _buildFileImage() {
    return Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ?? _defaultErrorWidget(),
    );
  }

  // File SVG
  Widget _buildFileSvg() {
    return SvgPicture.file(
      File(imagePath),
      width: width,
      height: height,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color!, colorBlendMode ?? BlendMode.srcIn)
          : null,
    );
  }

  // Helper methods
  bool _isNetworkUrl(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  bool _isAsset(String path) {
    return path.startsWith('assets/') ||
        path.startsWith('images/') ||
        !path.startsWith('/') && !_isNetworkUrl(path);
  }

  bool _isSvg(String path) {
    return path.toLowerCase().endsWith('.svg');
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _defaultErrorWidget() {
    final iconSize = (width != null && height != null)
        ? (width! < height! ? width! * 0.3 : height! * 0.3)
        : 24.0; // Ensure we have a default size

    // Ensure the size is valid
    final safeIconSize = iconSize.isFinite ? iconSize : 24.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: Icon(Icons.error_outline, color: Colors.red, size: safeIconSize),
    );
  }
}

// Extension for additional convenience methods
extension CustomImageExtension on CustomImage {
  // Create circular image
}

// Usage Examples:
/*
// Basic usage - just provide the path
UniversalImage(imagePath: 'assets/images/profile.jpg')

// Network image with caching
UniversalImage(
  imagePath: 'https://example.com/image.jpg',
  width: 200,
  height: 200,
  borderRadius: BorderRadius.circular(10),
)

// SVG from network
UniversalImage(
  imagePath: 'https://example.com/icon.svg',
  width: 50,
  height: 50,
  color: Colors.blue,
)

// File image
UniversalImage(
  imagePath: '/storage/emulated/0/Pictures/photo.jpg',
  width: 300,
  height: 200,
  fit: BoxFit.contain,
)

// Circular image using extension
UniversalImage.circular(
  imagePath: 'assets/images/avatar.png',
  size: 80,
)

// Rounded image using extension
UniversalImage.rounded(
  imagePath: 'https://example.com/banner.jpg',
  width: 300,
  height: 150,
  borderRadius: 15,
)

// With custom placeholder and error widgets
UniversalImage(
  imagePath: 'https://example.com/image.jpg',
  width: 200,
  height: 200,
  placeholder: Container(
    color: Colors.grey[300],
    child: Icon(Icons.image),
  ),
  errorWidget: Container(
    color: Colors.red[100],
    child: Icon(Icons.broken_image),
  ),
)
*/
