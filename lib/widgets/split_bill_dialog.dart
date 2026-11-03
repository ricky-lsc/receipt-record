import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/receipt.dart';
import '../models/receipt_split.dart';
import '../services/storage_service.dart';
import '../utils/currency_helper.dart';

class SplitBillDialog extends StatefulWidget {
  final Receipt receipt;

  const SplitBillDialog({super.key, required this.receipt});

  static Future<Receipt?> show(BuildContext context, Receipt receipt) {
    return showDialog<Receipt>(
      context: context,
      barrierDismissible: true,
      builder: (_) => SplitBillDialog(receipt: receipt),
    );
  }

  @override
  State<SplitBillDialog> createState() => _SplitBillDialogState();
}

class _SplitBillDialogState extends State<SplitBillDialog> {
  late List<SplitParticipant> _participants;
  late bool _isCustomized;
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _amountControllers = [];

  @override
  void initState() {
    super.initState();
    final existingSplit = widget.receipt.split;
    if (existingSplit != null && existingSplit.participants.isNotEmpty) {
      _participants = existingSplit.participants
          .map((p) => p.copyWith())
          .toList();
      _isCustomized = existingSplit.isCustomized;
    } else {
      _isCustomized = false;
      _participants = _createDefaultParticipants(2);
    }
    _syncControllers();
  }

  @override
  void dispose() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final c in _amountControllers) {
      c.dispose();
    }
    super.dispose();
  }

  List<SplitParticipant> _createDefaultParticipants(int count) {
    final list = <SplitParticipant>[];
    const uuid = Uuid();
    final total = widget.receipt.amount;
    final share = count > 0 ? (total / count) : 0.0;

    for (int i = 0; i < count; i++) {
      list.add(
        SplitParticipant(
          id: uuid.v4(),
          name: i == 0 ? 'Me' : 'Person ${i + 1}',
          amount: double.parse(share.toStringAsFixed(2)),
          isPaid: i == 0,
        ),
      );
    }
    return list;
  }

  void _syncControllers() {
    for (final c in _nameControllers) {
      c.dispose();
    }
    for (final c in _amountControllers) {
      c.dispose();
    }
    _nameControllers.clear();
    _amountControllers.clear();

    for (final p in _participants) {
      final nameCtrl = TextEditingController(text: p.name);
      nameCtrl.addListener(() {
        p.name = nameCtrl.text.trim();
      });
      _nameControllers.add(nameCtrl);

      final amtCtrl = TextEditingController(text: p.amount.toStringAsFixed(2));
      amtCtrl.addListener(() {
        final val = double.tryParse(amtCtrl.text.trim());
        if (val != null) {
          p.amount = val;
          setState(() {});
        }
      });
      _amountControllers.add(amtCtrl);
    }
  }

  void _recalculateEqualSplit() {
    if (_participants.isEmpty) return;
    final total = widget.receipt.amount;
    final share = double.parse((total / _participants.length).toStringAsFixed(2));

    for (int i = 0; i < _participants.length; i++) {
      _participants[i].amount = share;
      if (i < _amountControllers.length) {
        _amountControllers[i].text = share.toStringAsFixed(2);
      }
    }
    setState(() {
      _isCustomized = false;
    });
  }

  void _setPeopleCount(int targetCount) {
    if (targetCount < 2 || targetCount > 20) return;
    const uuid = Uuid();

    if (targetCount > _participants.length) {
      while (_participants.length < targetCount) {
        final idx = _participants.length + 1;
        _participants.add(
          SplitParticipant(
            id: uuid.v4(),
            name: 'Person $idx',
            amount: 0.0,
          ),
        );
      }
    } else if (targetCount < _participants.length) {
      _participants.removeRange(targetCount, _participants.length);
    }

    if (!_isCustomized) {
      _recalculateEqualSplit();
    }
    _syncControllers();
    setState(() {});
  }

  void _addParticipant() {
    _setPeopleCount(_participants.length + 1);
  }

  void _removeParticipant(int index) {
    if (_participants.length <= 2) return;
    _participants.removeAt(index);
    if (!_isCustomized) {
      _recalculateEqualSplit();
    }
    _syncControllers();
    setState(() {});
  }

  void _autoBalanceRemainder() {
    final total = widget.receipt.amount;
    if (_participants.length <= 1) return;

    // Allocate remaining to everyone except the first participant ("Me")
    final meAmount = _participants[0].amount;
    final remainingForOthers = total - meAmount;
    final othersCount = _participants.length - 1;

    if (othersCount > 0) {
      final share = double.parse((remainingForOthers / othersCount).toStringAsFixed(2));
      for (int i = 1; i < _participants.length; i++) {
        _participants[i].amount = share >= 0 ? share : 0.0;
        if (i < _amountControllers.length) {
          _amountControllers[i].text = _participants[i].amount.toStringAsFixed(2);
        }
      }
      setState(() {
        _isCustomized = true;
      });
    }
  }

  double get _totalAllocated =>
      _participants.fold(0.0, (sum, p) => sum + p.amount);

  double get _difference => widget.receipt.amount - _totalAllocated;

  String _generateShareText(AppLocalizations l10n) {
    final buffer = StringBuffer();
    final dateStr = DateFormat('yyyy-MM-dd').format(widget.receipt.date);
    buffer.writeln('🧾 ${l10n.splitBillTitle}: ${widget.receipt.merchant}');
    buffer.writeln('📅 $dateStr • ${l10n.total}: ${CurrencyHelper.format(widget.receipt.amount, symbol: widget.receipt.currency)}');
    buffer.writeln('--------------------------------');

    for (final p in _participants) {
      final status = p.isPaid ? ' (${l10n.markPaid})' : '';
      buffer.writeln('• ${p.name.isNotEmpty ? p.name : l10n.participant}: ${CurrencyHelper.format(p.amount, symbol: widget.receipt.currency)}$status');
    }

    buffer.writeln('--------------------------------');
    buffer.writeln(l10n.appTitle);
    return buffer.toString();
  }

  Future<void> _copyBreakdown(AppLocalizations l10n) async {
    final text = _generateShareText(l10n);
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.copiedToClipboard),
          backgroundColor: const Color(0xFF0F766E),
        ),
      );
    }
  }

  Future<void> _saveSplit(AppLocalizations l10n) async {
    final split = ReceiptSplit(
      participants: _participants,
      isCustomized: _isCustomized,
    );
    final updatedReceipt = widget.receipt.copyWith(split: split);
    await StorageService.instance.saveReceipt(updatedReceipt);

    if (mounted) {
      Navigator.of(context).pop(updatedReceipt);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.splitSaved),
          backgroundColor: const Color(0xFF0F766E),
        ),
      );
    }
  }

  Future<void> _clearSplit(AppLocalizations l10n) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.clearSplit),
        content: Text(l10n.clearSplitConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.clearSplit),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final updatedReceipt = widget.receipt.copyWith(split: null);
      await StorageService.instance.saveReceipt(updatedReceipt);
      if (mounted) {
        Navigator.of(context).pop(updatedReceipt);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currency = widget.receipt.currency;
    final totalAmount = widget.receipt.amount;
    final allocated = _totalAllocated;
    final diff = _difference;
    final isBalanced = diff.abs() < 0.05;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                      Icons.call_split,
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
                          l10n.splitBillTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.receipt.merchant} • ${CurrencyHelper.format(totalAmount, symbol: currency)}',
                          style: const TextStyle(
                            fontSize: 13,
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

              // People count and Mode Row
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  // People count selector
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.numberOfPeople,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        onPressed: _participants.length > 2
                            ? () => _setPeopleCount(_participants.length - 1)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '${_participants.length}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton.filledTonal(
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                        onPressed: _participants.length < 20
                            ? () => _setPeopleCount(_participants.length + 1)
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  // Equal vs Custom Toggle
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: false,
                        label: Text(l10n.equalSplit, style: const TextStyle(fontSize: 12)),
                      ),
                      ButtonSegment(
                        value: true,
                        label: Text(l10n.customSplit, style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                    selected: {_isCustomized},
                    onSelectionChanged: (set) {
                      final val = set.first;
                      if (!val) {
                        _recalculateEqualSplit();
                      } else {
                        setState(() => _isCustomized = true);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Balance & Allocation Summary Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isBalanced
                      ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
                      : (diff > 0
                          ? (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7))
                          : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2))),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isBalanced ? Icons.check_circle : Icons.info_outline,
                          size: 18,
                          color: isBalanced
                              ? Colors.green
                              : (diff > 0 ? Colors.amber[800] : Colors.red),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isBalanced
                              ? '${l10n.totalAllocated}: ${CurrencyHelper.format(allocated, symbol: currency)} (${l10n.balanced})'
                              : (diff > 0
                                  ? '${l10n.remainingBalance}: ${CurrencyHelper.format(diff, symbol: currency)} (${l10n.totalAllocated}: ${CurrencyHelper.format(allocated, symbol: currency)})'
                                  : '${l10n.overAllocated}: ${CurrencyHelper.format(diff.abs(), symbol: currency)} (${l10n.totalAllocated}: ${CurrencyHelper.format(allocated, symbol: currency)})'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isBalanced
                                ? (isDark ? Colors.green[100] : const Color(0xFF065F46))
                                : (diff > 0
                                    ? (isDark ? Colors.amber[100] : const Color(0xFF92400E))
                                    : (isDark ? Colors.red[100] : const Color(0xFF991B1B))),
                          ),
                        ),
                      ],
                    ),
                    if (!isBalanced && _isCustomized)
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: _autoBalanceRemainder,
                        icon: const Icon(Icons.auto_fix_high, size: 14),
                        label: Text(l10n.distributeRemaining, style: const TextStyle(fontSize: 12)),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Scrollable Participant List
              Expanded(
                child: ListView.separated(
                  itemCount: _participants.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final p = _participants[idx];
                    final nameCtrl = idx < _nameControllers.length ? _nameControllers[idx] : null;
                    final amtCtrl = idx < _amountControllers.length ? _amountControllers[idx] : null;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Participant Number / Paid toggle
                          InkWell(
                            onTap: () {
                              setState(() {
                                p.isPaid = !p.isPaid;
                              });
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: p.isPaid
                                    ? const Color(0xFF0F766E).withValues(alpha: 0.15)
                                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    p.isPaid ? Icons.check_circle : Icons.radio_button_unchecked,
                                    size: 14,
                                    color: p.isPaid ? const Color(0xFF0F766E) : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    p.isPaid ? l10n.markPaid : l10n.markUnpaid,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: p.isPaid ? const Color(0xFF0F766E) : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Name field
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: nameCtrl,
                              decoration: InputDecoration(
                                hintText: idx == 0 ? l10n.me : '${l10n.participant} ${idx + 1}',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Amount field
                          Expanded(
                            flex: 2,
                            child: TextField(
                              controller: amtCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                prefixText: '$currency ',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onChanged: (_) {
                                if (!_isCustomized) {
                                  setState(() => _isCustomized = true);
                                }
                              },
                            ),
                          ),

                          // Remove participant button
                          if (_participants.length > 2)
                            IconButton(
                              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                              tooltip: l10n.removePerson,
                              onPressed: () => _removeParticipant(idx),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Bottom Actions Toolbar
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _addParticipant,
                        icon: const Icon(Icons.person_add, size: 16),
                        label: Text(l10n.addPerson),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _copyBreakdown(l10n),
                        icon: const Icon(Icons.copy, size: 16),
                        label: Text(l10n.copyBreakdown),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (widget.receipt.split != null)
                        TextButton(
                          onPressed: () => _clearSplit(l10n),
                          child: Text(l10n.clearSplit, style: const TextStyle(color: Colors.red)),
                        ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F766E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _saveSplit(l10n),
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(l10n.saveSplit),
                      ),
                    ],
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
