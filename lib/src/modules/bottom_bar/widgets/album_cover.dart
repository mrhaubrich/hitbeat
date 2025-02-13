import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// {@template album_cover}
/// A widget that displays an album cover from different sources.
/// {@endtemplate}
class AlbumCover extends StatelessWidget {
  const AlbumCover._({
    super.key,
    this.size = 64,
    this.padding = const EdgeInsets.all(8),
    this.borderRadius = 8,
    this.backgroundColor,
    this.placeholderIcon = const Icon(Icons.album, size: 32),
    this.imageUrl,
    this.imageFile,
    this.imageBytes,
    this.assetPath,
  });

  /// Creates an album cover from a network URL
  const AlbumCover.network({
    required String url,
    Key? key,
    double size = 64,
    EdgeInsets padding = const EdgeInsets.all(8),
    double borderRadius = 8,
    Color? backgroundColor,
    Widget placeholderIcon = const Icon(Icons.album, size: 32),
  }) : this._(
          key: key,
          imageUrl: url,
          size: size,
          padding: padding,
          borderRadius: borderRadius,
          backgroundColor: backgroundColor,
          placeholderIcon: placeholderIcon,
        );

  /// Creates an album cover from a local file
  const AlbumCover.file({
    required File file,
    Key? key,
    double size = 64,
    EdgeInsets padding = const EdgeInsets.all(8),
    double borderRadius = 8,
    Color? backgroundColor,
    Widget placeholderIcon = const Icon(Icons.album, size: 32),
  }) : this._(
          key: key,
          imageFile: file,
          size: size,
          padding: padding,
          borderRadius: borderRadius,
          backgroundColor: backgroundColor,
          placeholderIcon: placeholderIcon,
        );

  /// Creates an album cover from memory (bytes)
  const AlbumCover.memory({
    required Uint8List bytes,
    Key? key,
    double size = 64,
    EdgeInsets padding = const EdgeInsets.all(8),
    double borderRadius = 8,
    Color? backgroundColor,
    Widget placeholderIcon = const Icon(Icons.album, size: 32),
  }) : this._(
          key: key,
          imageBytes: bytes,
          size: size,
          padding: padding,
          borderRadius: borderRadius,
          backgroundColor: backgroundColor,
          placeholderIcon: placeholderIcon,
        );

  /// Creates an album cover from an asset
  const AlbumCover.asset({
    required String path,
    Key? key,
    double size = 64,
    EdgeInsets padding = const EdgeInsets.all(8),
    double borderRadius = 8,
    Color? backgroundColor,
    Widget placeholderIcon = const Icon(Icons.album, size: 32),
  }) : this._(
          key: key,
          assetPath: path,
          size: size,
          padding: padding,
          borderRadius: borderRadius,
          backgroundColor: backgroundColor,
          placeholderIcon: placeholderIcon,
        );

  /// The URL of the image to display.
  final String? imageUrl;

  /// The file of the image to display.
  final File? imageFile;

  /// The bytes of the image to display.
  final Uint8List? imageBytes;

  /// The asset path of the image to display.
  final String? assetPath;

  /// The size of the album cover.
  final double size;

  /// The padding around the album cover.
  final EdgeInsets padding;

  /// The border radius of the album cover.
  final double borderRadius;

  /// The background color of the album cover.
  final Color? backgroundColor;

  /// The icon to display when the image is loading or fails to load.
  final Widget placeholderIcon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          width: size,
          height: size,
          color: backgroundColor ?? Colors.grey[300],
          child: _buildImage(),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => placeholderIcon,
      );
    }

    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholderIcon,
      );
    }

    if (imageBytes != null) {
      return Image.memory(
        imageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholderIcon,
      );
    }

    if (assetPath != null) {
      return Image.asset(
        assetPath!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => placeholderIcon,
      );
    }

    return placeholderIcon;
  }
}
