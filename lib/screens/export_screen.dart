import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/receipt.dart';
import '../models/receipt_category.dart';
import '../services/export_service.dart';
import '../services/locale_service.dart';
import '../services/storage_service.dart';
import '../utils/currency_helper.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  ExportFormat _selectedFormat = ExportFormat.csv;
  String _selectedCategory = 'all';
  bool _isExporting = false;
  bool _showPreview = false;

  List<Receipt> _filterReceipts(List<Receipt> receipts) {
    if (_selectedCategory == 'all') return receipts;
    return receipts.where((r) => r.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  String _getPreviewContent(List<Receipt> receipts) {
    switch (_selectedFormat) {
      case ExportFormat.csv:
        return ExportService.generateCsv(receipts);
      case ExportFormat.json:
        return ExportService.generateJson(receipts);
      case ExportFormat.markdown:
        return ExportService.generateMarkdownReport(receipts);
    }
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
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  result.success ? Icons.check_circle : Icons.info_outline,
                  color: result.success ? Colors.green : Colors.amber,
                ),
                const SizedBox(width: 8),
                Text(result.success ? l10n.exportSuccess : l10n.exportAsFile),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result.message ?? l10n.exportSuccess),
                if (result.filePath != null) ...[
                  const SizedBox(height: 12),
                  const Text('File Location:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  SelectableText(
                    result.filePath!,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.blue),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: result.content));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.pasteFromClipboard)),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy Content'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.close),
              ),
            ],
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

  void _copyToClipboard(List<Receipt> receipts) {
    final l10n = AppLocalizations.of(context);
    if (receipts.isEmpty) return;
    final content = _getPreviewContent(receipts);
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.exportSuccess)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<List<Receipt>>(
      valueListenable: StorageService.instance.receiptsNotifier,
      builder: (context, allReceipts, _) {
        final filteredReceipts = _filterReceipts(allReceipts);
        final totalAmount = filteredReceipts.fold<double>(0.0, (sum, r) => sum + r.amount);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.exportReceipts),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFF0F766E).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFF0F766E).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.file_download, color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.exportReceipts,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.exportDescription,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Filter Scope Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.category.toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${l10n.category}: ${_selectedCategory == 'all' ? l10n.categoryAll : LocaleService.getCategoryName(_selectedCategory, l10n)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${filteredReceipts.length} ${l10n.receiptCountSuffix} • ${CurrencyHelper.format(totalAmount)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
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
              const SizedBox(height: 16),

              // Export Format Cards
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.exportFormat.toUpperCase(),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
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
                            const Divider(height: 16),
                            _buildFormatOption(
                              format: ExportFormat.markdown,
                              title: 'Markdown / Text (.md)',
                              subtitle: l10n.exportDescription,
                              icon: Icons.description,
                              iconColor: Colors.blue,
                            ),
                            const Divider(height: 16),
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
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _isExporting ? null : () => _handleSaveToFile(filteredReceipts),
                        icon: _isExporting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.save_alt),
                        label: Text(l10n.exportAsFile),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _copyToClipboard(filteredReceipts),
                      icon: const Icon(Icons.copy),
                      label: Text(l10n.pasteFromClipboard),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Live Preview Toggle & Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.remove_red_eye_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(l10n.viewText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            ],
                          ),
                          Switch(
                            value: _showPreview,
                            onChanged: (val) => setState(() => _showPreview = val),
                          ),
                        ],
                      ),
                      if (_showPreview) ...[
                        const Divider(height: 16),
                        Container(
                          width: double.infinity,
                          height: 260,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _getPreviewContent(filteredReceipts),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
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
                  const SizedBox(height: 2),
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
}
