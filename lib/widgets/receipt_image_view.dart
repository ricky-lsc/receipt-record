import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

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

  File? _resolveImageFile() {
    if (kIsWeb || imagePath == null || imagePath!.isEmpty) return null;
    final file = File(imagePath!);
    if (file.existsSync()) return file;

    // Check if relative to custom storage path or default storage
    final customPath = StorageService.instance.customStoragePathNotifier.value;
    if (customPath != null && customPath.isNotEmpty) {
      final relativeFile = File('$customPath/$imagePath');
      if (relativeFile.existsSync()) return relativeFile;

      final inImagesDir = File('$customPath/receipt_images/${file.uri.pathSegments.last}');
      if (inImagesDir.existsSync()) return inImagesDir;
    }

    return null;
  }

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
    // 1. Prefer physical file on disk (streams directly without keeping in memory)
    final file = _resolveImageFile();
    if (file != null) {
      return Image.file(
        file,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
      );
    }

    // 2. Fallback to memory bytes if only base64 is available
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
    final file = _resolveImageFile();
    final bytes = file == null ? _getImageBytes() : null;

    if (file == null && bytes == null) return;

    final TransformationController transformController = TransformationController();
    TapDownDetails? doubleTapDetails;

    void zoomAroundPoint(Offset focalPoint, double scaleFactor) {
      final currentMatrix = transformController.value;
      final currentScale = currentMatrix.getMaxScaleOnAxis();
      final targetScale = (currentScale * scaleFactor).clamp(0.5, 8.0);
      final factor = targetScale / currentScale;

      final matrix = Matrix4.translationValues(focalPoint.dx, focalPoint.dy, 0.0)
        ..multiply(Matrix4.diagonal3Values(factor, factor, 1.0))
        ..multiply(Matrix4.translationValues(-focalPoint.dx, -focalPoint.dy, 0.0))
        ..multiply(currentMatrix);

      transformController.value = matrix;
    }

    void handleDoubleTap(Size viewportSize) {
      final currentScale = transformController.value.getMaxScaleOnAxis();
      if (currentScale > 1.2) {
        transformController.value = Matrix4.identity();
      } else {
        final focal = doubleTapDetails?.localPosition ??
            Offset(viewportSize.width / 2, viewportSize.height / 2);
        zoomAroundPoint(focal, 2.5);
      }
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.95),
      useSafeArea: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              // Full-screen interactive pan and focal-point zoom
              GestureDetector(
                onDoubleTapDown: (details) => doubleTapDetails = details,
                onDoubleTap: () => handleDoubleTap(MediaQuery.of(ctx).size),
                child: InteractiveViewer(
                  transformationController: transformController,
                  minScale: 0.5,
                  maxScale: 8.0,
                  boundaryMargin: const EdgeInsets.all(double.infinity),
                  child: Center(
                    child: file != null
                        ? Image.file(file, fit: BoxFit.contain)
                        : Image.memory(bytes!, fit: BoxFit.contain),
                  ),
                ),
              ),

              // Top bar with close button
              Positioned(
                top: MediaQuery.of(ctx).padding.top + 16,
                right: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 22),
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ),

              // Bottom zoom controls toolbar
              Positioned(
                bottom: MediaQuery.of(ctx).padding.bottom + 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.zoom_out, color: Colors.white, size: 20),
                        tooltip: 'Zoom Out',
                        onPressed: () {
                          final size = MediaQuery.of(ctx).size;
                          zoomAroundPoint(Offset(size.width / 2, size.height / 2), 0.8);
                        },
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () {
                          transformController.value = Matrix4.identity();
                        },
                        child: const Text('1:1 Reset', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.zoom_in, color: Colors.white, size: 20),
                        tooltip: 'Zoom In',
                        onPressed: () {
                          final size = MediaQuery.of(ctx).size;
                          zoomAroundPoint(Offset(size.width / 2, size.height / 2), 1.25);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
      imageContent = Hero(
        tag: heroTag!,
        child: imageContent,
      );
    }

    if (enableZoomOnTap) {
      return GestureDetector(
        onTap: () => _showFullScreenImage(context),
        child: imageContent,
      );
    }

    return imageContent;
  }
}
