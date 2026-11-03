import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/receipt.dart';
import '../models/receipt_category.dart';
import '../services/locale_service.dart';
import '../services/storage_service.dart';
import '../utils/currency_helper.dart';
import '../widgets/app_settings_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/import_preview_dialog.dart';
import '../widgets/language_selection_dialog.dart';
import '../widgets/receipt_card.dart';
import 'add_edit_receipt_screen.dart';
import 'receipt_detail_screen.dart';

enum SortOption {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc,
  merchantAsc;
}

String getSortOptionLabel(SortOption option, AppLocalizations l10n) {
  switch (option) {
    case SortOption.dateDesc:
      return l10n.sortDateDesc;
    case SortOption.dateAsc:
      return l10n.sortDateAsc;
    case SortOption.amountDesc:
      return l10n.sortAmountDesc;
    case SortOption.amountAsc:
      return l10n.sortAmountAsc;
    case SortOption.merchantAsc:
      return l10n.sortMerchantAsc;
  }
}

enum DateRangeFilter {
  all,
  thisMonth,
  lastMonth,
  thisYear;
}

String getDateRangeFilterLabel(DateRangeFilter filter, AppLocalizations l10n) {
  switch (filter) {
    case DateRangeFilter.all:
      return l10n.filterAll;
    case DateRangeFilter.thisMonth:
      return l10n.filterThisMonth;
    case DateRangeFilter.lastMonth:
      return l10n.filterLastMonth;
    case DateRangeFilter.thisYear:
      return l10n.filterThisYear;
  }
}

class ReceiptListScreen extends StatefulWidget {
  final VoidCallback onNavigateToAdd;
  final ValueNotifier<ThemeMode>? themeModeNotifier;

  const ReceiptListScreen({
    super.key,
    required this.onNavigateToAdd,
    this.themeModeNotifier,
  });

  @override
  State<ReceiptListScreen> createState() => _ReceiptListScreenState();
}

class _ReceiptListScreenState extends State<ReceiptListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _categoryScrollController = ScrollController();
  String _selectedCategory = 'all';
  SortOption _currentSort = SortOption.dateDesc;
  DateRangeFilter _dateFilter = DateRangeFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    _categoryScrollController.dispose();
    super.dispose();
  }

  List<Receipt> _filterAndSortReceipts(List<Receipt> rawReceipts) {
    final query = _searchController.text.trim().toLowerCase();
    final now = DateTime.now();

    final filtered = rawReceipts.where((r) {
      // Category filter
      if (_selectedCategory != 'all' &&
          r.category.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      // Date range filter
      switch (_dateFilter) {
        case DateRangeFilter.thisMonth:
          if (r.date.year != now.year || r.date.month != now.month) return false;
          break;
        case DateRangeFilter.lastMonth:
          final prevMonth = DateTime(now.year, now.month - 1);
          if (r.date.year != prevMonth.year || r.date.month != prevMonth.month) {
            return false;
          }
          break;
        case DateRangeFilter.thisYear:
          if (r.date.year != now.year) return false;
          break;
        case DateRangeFilter.all:
          break;
      }

      // Search query filter (merchant, category, items, notes)
      if (query.isNotEmpty) {
        final inMerchant = r.merchant.toLowerCase().contains(query);
        final inCategory = r.category.toLowerCase().contains(query);
        final inNotes = r.notes?.toLowerCase().contains(query) ?? false;
        final inItems = r.items.any((item) => item.name.toLowerCase().contains(query));
        return inMerchant || inCategory || inNotes || inItems;
      }

      return true;
    }).toList();

    // Sort receipts
    filtered.sort((a, b) {
      switch (_currentSort) {
        case SortOption.dateDesc:
          return b.date.compareTo(a.date);
        case SortOption.dateAsc:
          return a.date.compareTo(b.date);
        case SortOption.amountDesc:
          return b.amount.compareTo(a.amount);
        case SortOption.amountAsc:
          return a.amount.compareTo(b.amount);
        case SortOption.merchantAsc:
          return a.merchant.toLowerCase().compareTo(b.merchant.toLowerCase());
      }
    });

    return filtered;
  }

  void _showSortFilterModal() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.sortAndFilter, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Text(l10n.sortAndFilter.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    RadioGroup<SortOption>(
                      groupValue: _currentSort,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _currentSort = val);
                          setModalState(() => _currentSort = val);
                          Navigator.of(ctx).pop();
                        }
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: SortOption.values
                            .map((sort) => RadioListTile<SortOption>(
                                  dense: true,
                                  title: Text(getSortOptionLabel(sort, l10n)),
                                  value: sort,
                                ))
                            .toList(),
                      ),
                    ),
                    const Divider(),
                    Text(l10n.dateRange.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: DateRangeFilter.values.map((df) {
                        final isSelected = _dateFilter == df;
                        return ChoiceChip(
                          label: Text(getDateRangeFilterLabel(df, l10n)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _dateFilter = df);
                              setModalState(() => _dateFilter = df);
                              Navigator.of(ctx).pop();
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
        final filteredReceipts = _filterAndSortReceipts(allReceipts);
        final totalAmount = filteredReceipts.fold<double>(0.0, (sum, r) => sum + r.amount);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.receiptRecords),
            actions: [
              IconButton(
                icon: const Icon(Icons.language),
                tooltip: l10n.chooseLanguageTooltip,
                onPressed: () => LanguageSelectionDialog.show(context),
              ),
              IconButton(
                icon: const Icon(Icons.sort),
                tooltip: l10n.sortAndFilter,
                onPressed: _showSortFilterModal,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (val) async {
                  if (val == 'import') {
                    await ImportPreviewDialog.pickAndShow(context);
                  } else if (val == 'clear') {
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
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'import',
                    child: Row(
                      children: [
                        const Icon(Icons.file_upload_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.importBackup),
                      ],
                    ),
                  ),
                  if (allReceipts.isNotEmpty)
                    PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(l10n.clearAllData, style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
              ),
              if (widget.themeModeNotifier != null)
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  tooltip: l10n.settingsHub,
                  onPressed: () => AppSettingsDialog.show(context, widget.themeModeNotifier!),
                ),
            ],
          ),
          body: Column(
            children: [
              // Search & Quick Filter Bar
              Container(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: l10n.searchPlaceholder,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    // Category Chips Bar
                    Listener(
                      onPointerSignal: (pointerSignal) {
                        if (pointerSignal is PointerScrollEvent && _categoryScrollController.hasClients) {
                          final targetOffset = (_categoryScrollController.offset + pointerSignal.scrollDelta.dy)
                              .clamp(0.0, _categoryScrollController.position.maxScrollExtent);
                          _categoryScrollController.jumpTo(targetOffset);
                        }
                      },
                      child: SingleChildScrollView(
                        controller: _categoryScrollController,
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
                                  avatar: Icon(cat.icon, size: 14, color: isSelected ? Colors.white : cat.color),
                                  label: Text(LocaleService.getCategoryName(cat.id, l10n)),
                                  selected: isSelected,
                                  selectedColor: cat.color,
                                  onSelected: (val) {
                                    setState(() {
                                      _selectedCategory = val ? cat.id : 'all';
                                    });
                                  },
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Filter Summary Header
              if (allReceipts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredReceipts.length} ${l10n.receiptCountSuffix}${_dateFilter != DateRangeFilter.all ? ' • ${getDateRangeFilterLabel(_dateFilter, l10n)}' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '${l10n.totalSpent}: ${CurrencyHelper.format(totalAmount)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
                        ),
                      ),
                    ],
                  ),
                ),

              // Receipts List View
              Expanded(
                child: allReceipts.isEmpty
                    ? EmptyState(
                        icon: Icons.receipt_long,
                        title: l10n.noReceiptsFound,
                        message: l10n.noReceiptsDesc,
                        primaryActionLabel: l10n.recordReceipt,
                        onPrimaryAction: widget.onNavigateToAdd,
                      )
                    : filteredReceipts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                Text(l10n.noMatchingReceipts, style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(l10n.noMatchingReceiptsDesc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _selectedCategory = 'all';
                                      _dateFilter = DateRangeFilter.all;
                                    });
                                  },
                                  child: Text(l10n.categoryAll),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                            itemCount: filteredReceipts.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final receipt = filteredReceipts[i];
                              return ReceiptCard(
                                receipt: receipt,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ReceiptDetailScreen(receipt: receipt),
                                    ),
                                  );
                                },
                                onEdit: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AddEditReceiptScreen(existingReceipt: receipt),
                                    ),
                                  );
                                },
                                onDelete: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(l10n.deleteReceiptTitle),
                                      content: Text('${l10n.deleteReceiptConfirm}\n"${receipt.merchant}"'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                          child: Text(l10n.delete),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    await StorageService.instance.deleteReceipt(receipt.id);
                                  }
                                },
                              );
                            },
                          ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            heroTag: 'receipt_list_fab',
            onPressed: widget.onNavigateToAdd,
            tooltip: l10n.addReceiptTooltip,
            child: const Icon(Icons.add_a_photo),
          ),
        );
      },
    );
  }
}
