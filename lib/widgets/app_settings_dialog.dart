import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../screens/export_screen.dart';
import '../services/glm_receipt_service.dart';
import '../services/locale_service.dart';
import '../services/storage_service.dart';
import '../services/theme_service.dart';
import 'cloud_ai_settings_dialog.dart';
import 'import_preview_dialog.dart';
import 'language_selection_dialog.dart';
import 'storage_settings_dialog.dart';

class AppSettingsDialog extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const AppSettingsDialog({super.key, required this.themeModeNotifier});

  static Future<void> show(BuildContext context, ValueNotifier<ThemeMode> themeModeNotifier) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AppSettingsDialog(themeModeNotifier: themeModeNotifier),
    );
  }

  @override
  State<AppSettingsDialog> createState() => _AppSettingsDialogState();
}

class _AppSettingsDialogState extends State<AppSettingsDialog> {
  bool _hasAiKey = false;

  @override
  void initState() {
    super.initState();
    _refreshAiStatus();
  }

  Future<void> _refreshAiStatus() async {
    final hasKey = await GlmReceiptService.instance.hasApiKey();
    if (mounted) {
      setState(() {
        _hasAiKey = hasKey;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.settings_outlined, color: Color(0xFF0F766E), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.settingsHub,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l10n.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              Expanded(
                child: ListView(
                  children: [
                    // Section 1: Appearance
                    Text(
                      l10n.themeAppearance.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<ThemeMode>(
                      valueListenable: widget.themeModeNotifier,
                      builder: (context, currentMode, _) {
                        return SegmentedButton<ThemeMode>(
                          segments: [
                            ButtonSegment(
                              value: ThemeMode.system,
                              icon: const Icon(Icons.brightness_auto, size: 16),
                              label: Text(l10n.themeSystem, style: const TextStyle(fontSize: 12)),
                            ),
                            ButtonSegment(
                              value: ThemeMode.light,
                              icon: const Icon(Icons.light_mode, size: 16),
                              label: Text(l10n.themeLight, style: const TextStyle(fontSize: 12)),
                            ),
                            ButtonSegment(
                              value: ThemeMode.dark,
                              icon: const Icon(Icons.dark_mode, size: 16),
                              label: Text(l10n.themeDark, style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                          selected: {currentMode},
                          onSelectionChanged: (Set<ThemeMode> newSelection) {
                            final mode = newSelection.first;
                            widget.themeModeNotifier.value = mode;
                            ThemeService.instance.setThemeMode(mode);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Section 2: General & Integrations
                    Text(
                      l10n.settingsHub.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Card(
                      child: Column(
                        children: [
                          // Language Tile
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.language, color: Colors.indigo, size: 20),
                            ),
                            title: Text(l10n.language, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: ValueListenableBuilder<Locale?>(
                              valueListenable: LocaleService.instance.localeNotifier,
                              builder: (context, locale, _) {
                                String langLabel;
                                if (locale == null) {
                                  langLabel = l10n.followSystem;
                                } else if (locale.languageCode == 'zh') {
                                  langLabel = locale.scriptCode == 'Hant' ? '繁體中文' : '简体中文';
                                } else {
                                  langLabel = 'English';
                                }
                                return Text(langLabel, style: const TextStyle(fontSize: 12));
                              },
                            ),
                            trailing: const Icon(Icons.chevron_right, size: 20),
                            onTap: () => LanguageSelectionDialog.show(context),
                          ),
                          const Divider(height: 1),

                          // Cloud AI Tile
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.auto_awesome, color: Color(0xFF0F766E), size: 20),
                            ),
                            title: Text(l10n.cloudAiSettings, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(
                              _hasAiKey ? l10n.byokBadge : l10n.apiKeyHint,
                              style: TextStyle(
                                fontSize: 12,
                                color: _hasAiKey ? const Color(0xFF0F766E) : Colors.grey,
                              ),
                            ),
                            trailing: const Icon(Icons.chevron_right, size: 20),
                            onTap: () async {
                              await CloudAiSettingsDialog.show(context);
                              await _refreshAiStatus();
                            },
                          ),
                          const Divider(height: 1),

                          // Storage & Backups Tile
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.folder_shared_outlined, color: Colors.amber, size: 20),
                            ),
                            title: Text(l10n.storageSettings, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: ValueListenableBuilder<String?>(
                              valueListenable: StorageService.instance.customStoragePathNotifier,
                              builder: (context, customPath, _) {
                                final isCustom = customPath != null && customPath.isNotEmpty;
                                return Text(
                                  isCustom ? l10n.customStorage : l10n.defaultStorage,
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                            trailing: const Icon(Icons.chevron_right, size: 20),
                            onTap: () => StorageSettingsDialog.show(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Section 3: Data Management (Export & Restore)
                    Text(
                      l10n.dataManagement.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Card(
                      child: Column(
                        children: [
                          // Export Receipts Tile
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.file_download_outlined, color: Color(0xFF0F766E), size: 20),
                            ),
                            title: Text(l10n.exportReceipts, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(l10n.exportDescription, style: const TextStyle(fontSize: 12)),
                            trailing: const Icon(Icons.chevron_right, size: 20),
                            onTap: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const ExportScreen()),
                              );
                            },
                          ),
                          const Divider(height: 1),

                          // Import & Restore Tile
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.file_upload_outlined, color: Colors.blue, size: 20),
                            ),
                            title: Text(l10n.importReceipts, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(l10n.importDescription, style: const TextStyle(fontSize: 12)),
                            trailing: const Icon(Icons.chevron_right, size: 20),
                            onTap: () async {
                              await ImportPreviewDialog.pickAndShow(context);
                            },
                          ),
                          const Divider(height: 1),

                          // Clear All Data Tile
                          ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                            ),
                            title: Text(l10n.clearAllData, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.red)),
                            trailing: const Icon(Icons.chevron_right, size: 20),
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(l10n.clearAllReceiptsTitle),
                                  content: Text(l10n.clearAllReceiptsConfirm),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: Text(l10n.clearAll),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await StorageService.instance.clearAll();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // App Info Footer
                    Center(
                      child: Text(
                        '${l10n.appTitle} • v1.0.0',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
