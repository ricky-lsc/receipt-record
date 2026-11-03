import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../screens/add_edit_receipt_screen.dart';

class QuickReceiptActionSheet {
  static final ImagePicker _picker = ImagePicker();

  static Future<void> show(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.recordReceipt,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.photoUploadSubtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Option 1: Camera
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: Color(0xFF0F766E)),
                ),
                title: Text(l10n.takePhoto, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text(l10n.takePhotoSubtitle, style: const TextStyle(fontSize: 12)),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _pickAndNavigate(context, ImageSource.camera);
                },
              ),

              // Option 2: Gallery
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.blue),
                ),
                title: Text(l10n.chooseFromGallery, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text(l10n.chooseFromGallerySubtitle, style: const TextStyle(fontSize: 12)),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await _pickAndNavigate(context, ImageSource.gallery);
                },
              ),

              const Divider(height: 12),

              // Option 3: Manual Entry
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_note, color: Colors.amber),
                ),
                title: Text(l10n.manualEntry, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text(l10n.manualEntrySubtitle, style: const TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AddEditReceiptScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _pickAndNavigate(BuildContext context, ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (pickedFile != null && context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AddEditReceiptScreen(
              initialImagePath: pickedFile.path,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image in QuickReceiptActionSheet: $e');
      if (context.mounted) {
        if (source == ImageSource.camera) {
          // Camera not supported fallback
          final selectFile = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.cameraNotAvailable),
              content: Text(l10n.cameraNotAvailableDesc),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(l10n.chooseFromFiles),
                ),
              ],
            ),
          );
          if (selectFile == true && context.mounted) {
            _pickAndNavigate(context, ImageSource.gallery);
          }
        }
      }
    }
  }
}
