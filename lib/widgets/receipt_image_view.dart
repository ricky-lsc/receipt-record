import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReceiptImageView extends StatelessWidget {
  final String? imageBase64;
  final String? imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool enableZoomOnTap;
  final String? heroTag;

  const ReceiptImageView({
    super.key,
    this.imageBase64,
    this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.enableZoomOnTap = false,
    this.heroTag,
  });

  Uint8List? _getImageBytes() {
    if (imageBase64 != null && imageBase64!.isNotEmpty) {
      try {
        return base64Decode(imageBase64!);
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
      }
    }
    return null;
  }

  Widget _buildImageWidget(BuildContext context) {
    final bytes = _getImageBytes();
    if (bytes != null) {
      return Image.memory(
        bytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
      );
    }

    if (!kIsWeb && imagePath != null && imagePath!.isNotEmpty) {
      final file = File(imagePath!);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
        );
      }
    }

    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Center(
        child: Icon(
          Icons.receipt_outlined,
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          size: (width != null && width! < 60) ? 24 : 36,
        ),
      ),
    );
  }

  void _showFullScreenImage(BuildContext context) {
    final bytes = _getImageBytes();
    final bool hasFile = !kIsWeb && imagePath != null && File(imagePath!).existsSync();

    if (bytes == null && !hasFile) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.5,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: bytes != null
                    ? Image.memory(bytes, fit: BoxFit.contain)
                    : Image.file(File(imagePath!), fit: BoxFit.contain),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                radius: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pinch, color: Colors.white70, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Pinch or drag to zoom',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(8);

    Widget imageContent = ClipRRect(
      borderRadius: radius,
      child: _buildImageWidget(context),
    );

    if (heroTag != null) {
      imageContent = Hero(tag: heroTag!, child: imageContent);
    }

    if (enableZoomOnTap &&
        ((imageBase64 != null && imageBase64!.isNotEmpty) ||
            (!kIsWeb && imagePath != null && imagePath!.isNotEmpty))) {
      return GestureDetector(
        onTap: () => _showFullScreenImage(context),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Stack(
            children: [
              imageContent,
              Positioned(
                bottom: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.fullscreen,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return imageContent;
  }
}
