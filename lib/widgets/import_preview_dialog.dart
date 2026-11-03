import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/receipt.dart';
import '../services/export_service.dart';
import '../services/storage_service.dart';
import '../utils/currency_helper.dart';

class ImportPreviewDialog extends StatefulWidget {
  final List<Receipt> initialReceipts;
  final String format;
  final String fileName;

  const ImportPreviewDialog({
    super.key,
    required this.initialReceipts,
    required this.format,
    required this.fileName,
  });

  static Future<bool?> show(
    BuildContext context, {
    required List<Receipt> receipts,
    required String format,
    required String fileName,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => ImportPreviewDialog(
        initialReceipts: receipts,
        format: format,
        fileName: fileName,
      ),
    );
  }

  /// Helper to pick file and immediately open preview dialog
  static Future<bool?> pickAndShow(BuildContext context) async {
    final result = await ExportService.pickAndParseBackupFile();
    if (!context.mounted) return null;

    if (!result.success) {
      if (result.message != null && result.message != 'No file selected.') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message!),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }

    if (result.receipts.isEmpty) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noValidReceiptsFound),
          backgroundColor: Colors.amber,
        ),
      );
      return null;
    }

    return show(
      context,
      receipts: result.receipts,
      format: result.format,
      fileName: result.message ?? 'backup',
    );
  }

  @override
  State<ImportPreviewDialog> createState() => _ImportPreviewDialogState();
}

class _ImportPreviewDialogState extends State<ImportPreviewDialog> {
  bool _overwrite = false;
  bool _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final receipts = widget.initialReceipts;

    final totalSpending = receipts.fold<double>(0.0, (sum, r) => sum + r.amount);

    DateTime? earliest;
    DateTime? latest;
    for (final r in receipts) {
      if (earliest == null || r.date.isBefore(earliest)) earliest = r.date;
      if (latest == null || r.date.isAfter(latest)) latest = r.date;
    }

    final dateSpanStr = (earliest != null && latest != null)
        ? '${DateFormat('yyyy-MM-dd').format(earliest)} ~ ${DateFormat('yyyy-MM-dd').format(latest)}'
        : null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
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
                      Icons.file_upload_outlined,
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
                          l10n.importPreview,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.format,
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

              // Summary Stats Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text(
                              l10n.navReceipts,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${receipts.length}',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 32, color: Colors.grey.withValues(alpha: 0.3)),
                        Column(
                          children: [
                            Text(
                              l10n.totalSpent,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              CurrencyHelper.format(totalSpending),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (dateSpanStr != null) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.date_range, size: 14, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            dateSpanStr,
                            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Import Strategy Selector
              Text(
                l10n.importMode.toUpperCase(),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),

              RadioGroup<bool>(
                groupValue: _overwrite,
                onChanged: (val) {
                  if (val != null) setState(() => _overwrite = val);
                },
                child: Column(
                  children: [
                    RadioListTile<bool>(
                      contentPadding: EdgeInsets.zero,
                      value: false,
                      title: Text(l10n.importMerge, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(l10n.importMergeDesc, style: const TextStyle(fontSize: 12)),
                    ),
                    RadioListTile<bool>(
                      contentPadding: EdgeInsets.zero,
                      value: true,
                      title: Text(l10n.importOverwrite, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.red)),
                      subtitle: Text(l10n.importOverwriteDesc, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions Toolbar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _overwrite ? Colors.red : const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _isImporting
                        ? null
                        : () async {
                            final nav = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            setState(() => _isImporting = true);
                            await StorageService.instance.importReceipts(
                              receipts,
                              overwrite: _overwrite,
                            );
                            if (!mounted) return;
                            nav.pop(true);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('${l10n.importSuccess} (${receipts.length})'),
                                backgroundColor: const Color(0xFF0F766E),
                              ),
                            );
                          },
                    icon: _isImporting
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check, size: 18),
                    label: Text(l10n.confirmImport),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
