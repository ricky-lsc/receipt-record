import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/receipt.dart';
import '../models/receipt_category.dart';
import '../services/storage_service.dart';
import '../utils/currency_helper.dart';
import '../utils/date_helper.dart';
import '../widgets/category_badge.dart';
import '../widgets/receipt_image_view.dart';
import 'add_edit_receipt_screen.dart';

class ReceiptDetailScreen extends StatefulWidget {
  final Receipt receipt;

  const ReceiptDetailScreen({super.key, required this.receipt});

  @override
  State<ReceiptDetailScreen> createState() => _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends State<ReceiptDetailScreen> {
  late Receipt _receipt;

  @override
  void initState() {
    super.initState();
    _receipt = widget.receipt;
  }

  Future<void> _editReceipt() async {
    final updated = await Navigator.of(context).push<Receipt>(
      MaterialPageRoute(
        builder: (_) => AddEditReceiptScreen(existingReceipt: _receipt),
      ),
    );

    if (updated != null && mounted) {
      setState(() => _receipt = updated);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Receipt'),
        content: Text('Are you sure you want to delete the receipt for "${_receipt.merchant}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await StorageService.instance.deleteReceipt(_receipt.id);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final payment = PaymentMethod.fromString(_receipt.paymentMethod);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Receipt',
            onPressed: _editReceipt,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: 'Delete Receipt',
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Receipt Photo Hero / Preview Card
          if (_receipt.hasImage) ...[
            Card(
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Container(
                    height: 280,
                    width: double.infinity,
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                    child: ReceiptImageView(
                      imageBase64: _receipt.imageBase64,
                      imagePath: _receipt.imagePath,
                      heroTag: 'receipt_img_${_receipt.id}',
                      fit: BoxFit.contain,
                      enableZoomOnTap: true,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Tap to Zoom', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Primary Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          _receipt.merchant,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      Text(
                        CurrencyHelper.format(_receipt.amount, symbol: _receipt.currency),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CategoryBadge(categoryId: _receipt.category),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(payment.icon, size: 14, color: isDark ? Colors.white70 : Colors.black87),
                            const SizedBox(width: 6),
                            Text(
                              payment.label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  // Date and Time breakdown
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Text(
                        DateHelper.formatReceiptDate(_receipt.date),
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Itemized Details (if items present)
          if (_receipt.items.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Itemized Bill',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${_receipt.items.length} items',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _receipt.items.length,
                      separatorBuilder: (_, _) => const Divider(height: 12),
                      itemBuilder: (context, i) {
                        final item = _receipt.items[i];
                        return Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  '${item.quantity}x',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.name,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              CurrencyHelper.format(item.totalPrice, symbol: _receipt.currency),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Financial Summary Breakdown Card (Tax, Tip, Total)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const Divider(height: 20),
                  if (_receipt.items.isNotEmpty) ...[
                    _buildSummaryRow(
                      'Subtotal',
                      CurrencyHelper.format(_receipt.itemsSubtotal, symbol: _receipt.currency),
                      isDark,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_receipt.taxAmount != null && _receipt.taxAmount! > 0) ...[
                    _buildSummaryRow(
                      'Tax',
                      CurrencyHelper.format(_receipt.taxAmount!, symbol: _receipt.currency),
                      isDark,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (_receipt.tipAmount != null && _receipt.tipAmount! > 0) ...[
                    _buildSummaryRow(
                      'Tip',
                      CurrencyHelper.format(_receipt.tipAmount!, symbol: _receipt.currency),
                      isDark,
                    ),
                    const SizedBox(height: 8),
                  ],
                  const Divider(height: 16),
                  _buildSummaryRow(
                    'Total Paid',
                    CurrencyHelper.format(_receipt.amount, symbol: _receipt.currency),
                    isDark,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Notes / Remarks (if present)
          if (_receipt.notes != null && _receipt.notes!.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notes, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Notes',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _receipt.notes!,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Metadata Info Footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Record ID: ${_receipt.id.substring(0, 8)}',
                  style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                ),
                Text(
                  'Created: ${DateFormat('yyyy-MM-dd').format(_receipt.createdAt)}',
                  style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 17 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold
                ? (isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E))
                : (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }
}
