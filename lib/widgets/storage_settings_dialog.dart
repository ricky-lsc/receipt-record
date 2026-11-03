import 'dart:io';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';

class StorageSettingsDialog extends StatefulWidget {
  const StorageSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const StorageSettingsDialog(),
    );
  }

  @override
  State<StorageSettingsDialog> createState() => _StorageSettingsDialogState();
}

class _StorageSettingsDialogState extends State<StorageSettingsDialog> {
  String? _customPath;
  String _defaultPath = '';
  bool _autoBackup = true;
  bool _isMigrating = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    final storage = StorageService.instance;
    _customPath = storage.customStoragePathNotifier.value;
    _autoBackup = storage.autoBackupNotifier.value;
    _loadDefaultPath();
  }

  Future<void> _loadDefaultPath() async {
    final def = await StorageService.instance.getDefaultStoragePath();
    if (mounted) {
      setState(() => _defaultPath = def);
    }
  }

  Future<void> _pickFolder() async {
    final l10n = AppLocalizations.of(context);
    try {
      final String? selectedPath = await getDirectoryPath(
        confirmButtonText: l10n.chooseFolder,
      );

      if (selectedPath != null && selectedPath.isNotEmpty) {
        final dir = Directory(selectedPath);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
        await StorageService.instance.setCustomStoragePath(selectedPath);
        if (!mounted) return;
        setState(() {
          _customPath = selectedPath;
          _statusMessage = null;
        });
      }
    } catch (e) {
      debugPrint('Error selecting directory: $e');
      if (mounted) {
        setState(() {
          _statusMessage = 'Could not access directory: $e';
        });
      }
    }
  }

  Future<void> _resetToDefault() async {
    await StorageService.instance.setCustomStoragePath(null);
    if (!mounted) return;
    setState(() {
      _customPath = null;
      _statusMessage = null;
    });
  }

  Future<void> _migrateReceipts() async {
    final target = _customPath;
    if (target == null || target.isEmpty) return;

    setState(() {
      _isMigrating = true;
      _statusMessage = null;
    });

    final count = await StorageService.instance.migrateExistingReceiptsToCustomPath(target);

    if (!mounted) return;
    setState(() {
      _isMigrating = false;
      _statusMessage = 'Successfully synced and migrated $count receipt images to custom directory.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUsingCustom = _customPath != null && _customPath!.isNotEmpty;
    final activePath = isUsingCustom
        ? _customPath!
        : (_defaultPath.isNotEmpty ? _defaultPath : '...');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 680),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.folder_shared_outlined,
                            color: Color(0xFF0F766E),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.storageSettings,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isUsingCustom ? l10n.customStorage : l10n.defaultStorage,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: l10n.close,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Storage Location Mode Selector
                    Text(
                      l10n.storageMode.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),

                    RadioGroup<bool>(
                      groupValue: isUsingCustom,
                      onChanged: (val) {
                        if (val == true) {
                          _pickFolder();
                        } else {
                          _resetToDefault();
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Mode: Default Sandbox
                          RadioListTile<bool>(
                            contentPadding: EdgeInsets.zero,
                            value: false,
                            title: Text(l10n.defaultStorage, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(l10n.defaultStorageDesc, style: const TextStyle(fontSize: 12)),
                          ),

                          // Mode: Custom Directory
                          RadioListTile<bool>(
                            contentPadding: EdgeInsets.zero,
                            value: true,
                            title: Text(l10n.customStorage, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(l10n.customStorageDesc, style: const TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 20),

                    // Active Path Display Card
                    Text(
                      l10n.currentPath.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isUsingCustom ? Icons.folder_special : Icons.folder_outlined,
                            size: 20,
                            color: const Color(0xFF0F766E),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SelectableText(
                              activePath,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Directory Actions Toolbar
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickFolder,
                          icon: const Icon(Icons.drive_file_move_outlined, size: 16),
                          label: Text(l10n.chooseFolder),
                        ),
                        if (isUsingCustom) ...[
                          OutlinedButton.icon(
                            onPressed: _resetToDefault,
                            icon: const Icon(Icons.restart_alt, size: 16),
                            label: Text(l10n.resetToDefault),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                            ),
                            onPressed: _isMigrating ? null : _migrateReceipts,
                            icon: _isMigrating
                                ? const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.sync, size: 16),
                            label: Text(l10n.migrateReceipts),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 20),

                    // Auto-Backup Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        l10n.autoBackupTitle,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: Text(
                        l10n.autoBackupSubtitle,
                        style: const TextStyle(fontSize: 12),
                      ),
                      value: _autoBackup,
                      onChanged: (val) async {
                        setState(() => _autoBackup = val);
                        await StorageService.instance.setAutoBackup(val);
                      },
                    ),

                    // Status Message Banner
                    if (_statusMessage != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _statusMessage!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.green[100] : const Color(0xFF065F46),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // Close Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(l10n.close),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
