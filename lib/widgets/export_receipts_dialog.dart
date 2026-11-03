import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/receipt.dart';
import '../models/receipt_category.dart';
import '../services/export_service.dart';
import '../services/locale_service.dart';
import '../services/storage_service.dart';
import '../utils/currency_helper.dart';

class ExportReceiptsDialog extends StatefulWidget {
  const ExportReceiptsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ExportReceiptsDialog(),
    );
  }

  @override
  State<ExportReceiptsDialog> createState() => _ExportReceiptsDialogState();
}

class _ExportReceiptsDialogState extends State<ExportReceiptsDialog> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  String _selectedCategory = 'all';
  bool _isExporting = false;

  List<Receipt> _filterReceipts(List<Receipt> receipts) {
    if (_selectedCategory == 'all') return receipts;
    return receipts.where((r) => r.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  Future<void> _handleSaveToFile(List<Receipt> receipts) async {
    final l10n = AppLocalizations.of(context);
    if (receipts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noReceiptsFound)),
      );
      return;
    }

    setState(() => _isExporting = true);
    try {
      final result = await ExportService.exportToFile(
        receipts: receipts,
        format: _selectedFormat,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: result.success ? const Color(0xFF0F766E) : Colors.amber,
            content: Row(
              children: [
                Icon(
                  result.success ? Icons.check_circle : Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    result.message ?? l10n.exportSuccess,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      debugPrint('Export error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Widget _buildFormatOption({
    required ExportFormat format,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedFormat == format;

    return InkWell(
      onTap: () => setState(() => _selectedFormat = format),
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Radio<ExportFormat>(
              value: format,
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<List<Receipt>>(
      valueListenable: StorageService.instance.receiptsNotifier,
      builder: (context, allReceipts, _) {
        final filteredReceipts = _filterReceipts(allReceipts);
        final totalAmount = filteredReceipts.fold<double>(0.0, (sum, r) => sum + r.amount);

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 640),
            child: Padding(
              padding: const EdgeInsets.all(22),
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
                          Icons.file_download_outlined,
                          color: Color(0xFF0F766E),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.exportReceipts,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              l10n.exportDescription,
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

                  // Content Body
                  Expanded(
                    child: ListView(
                      children: [
                        // Category Filter Section
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.category.toUpperCase(),
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8),
                                    ),
                                    Text(
                                      '${filteredReceipts.length} ${l10n.receiptCountSuffix} • ${CurrencyHelper.format(totalAmount)}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                  child: Row(
                                    children: [
                                      ChoiceChip(
                                        label: Text(l10n.categoryAll),
                                        selected: _selectedCategory == 'all',
                                        onSelected: (val) {
                                          if (val) setState(() => _selectedCategory = 'all');
                                        },
                                      ),
                                      const SizedBox(width: 6),
                                      ...ReceiptCategory.defaults.map((cat) {
                                        final isSelected = _selectedCategory == cat.id;
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 6),
                                          child: ChoiceChip(
                                            label: Text(LocaleService.getCategoryName(cat.id, l10n)),
                                            selected: isSelected,
                                            onSelected: (val) {
                                              setState(() => _selectedCategory = val ? cat.id : 'all');
                                            },
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Format Selection Section
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.exportFormat.toUpperCase(),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8),
                                ),
                                const SizedBox(height: 8),
                                RadioGroup<ExportFormat>(
                                  groupValue: _selectedFormat,
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedFormat = val);
                                  },
                                  child: Column(
                                    children: [
                                      _buildFormatOption(
                                        format: ExportFormat.csv,
                                        title: l10n.csvFormat,
                                        subtitle: l10n.csvFormatDesc,
                                        icon: Icons.table_chart,
                                        iconColor: Colors.green,
                                      ),
                                      const Divider(height: 12),
                                      _buildFormatOption(
                                        format: ExportFormat.markdown,
                                        title: 'Markdown / Text (.md)',
                                        subtitle: l10n.exportDescription,
                                        icon: Icons.description,
                                        iconColor: Colors.blue,
                                      ),
                                      const Divider(height: 12),
                                      _buildFormatOption(
                                        format: ExportFormat.json,
                                        title: l10n.jsonFormat,
                                        subtitle: l10n.jsonFormatDesc,
                                        icon: Icons.data_object,
                                        iconColor: Colors.amber,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Actions
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
                          backgroundColor: const Color(0xFF0F766E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _isExporting ? null : () => _handleSaveToFile(filteredReceipts),
                        icon: _isExporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save_alt, size: 16),
                        label: Text(l10n.exportAsFile),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
