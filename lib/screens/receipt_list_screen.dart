import 'package:flutter/material.dart';
import '../models/receipt.dart';
import '../models/receipt_category.dart';
import '../services/storage_service.dart';
import '../utils/currency_helper.dart';
import '../widgets/empty_state.dart';
import '../widgets/receipt_card.dart';
import 'add_edit_receipt_screen.dart';
import 'receipt_detail_screen.dart';

enum SortOption {
  dateDesc('Date: Newest First'),
  dateAsc('Date: Oldest First'),
  amountDesc('Amount: High to Low'),
  amountAsc('Amount: Low to High'),
  merchantAsc('Merchant: A to Z');

  final String label;
  const SortOption(this.label);
}

enum DateRangeFilter {
  all('All Time'),
  thisMonth('This Month'),
  lastMonth('Last Month'),
  thisYear('This Year');

  final String label;
  const DateRangeFilter(this.label);
}

class ReceiptListScreen extends StatefulWidget {
  final VoidCallback onNavigateToAdd;

  const ReceiptListScreen({super.key, required this.onNavigateToAdd});

  @override
  State<ReceiptListScreen> createState() => _ReceiptListScreenState();
}

class _ReceiptListScreenState extends State<ReceiptListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'all';
  SortOption _currentSort = SortOption.dateDesc;
  DateRangeFilter _dateFilter = DateRangeFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
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

      // Date Range filter
      if (_dateFilter == DateRangeFilter.thisMonth) {
        if (r.date.year != now.year || r.date.month != now.month) return false;
      } else if (_dateFilter == DateRangeFilter.lastMonth) {
        final lastMonthDate = DateTime(now.year, now.month - 1, 1);
        if (r.date.year != lastMonthDate.year || r.date.month != lastMonthDate.month) return false;
      } else if (_dateFilter == DateRangeFilter.thisYear) {
        if (r.date.year != now.year) return false;
      }

      // Search query filter (merchant, notes, category, item names)
      if (query.isNotEmpty) {
        final matchesMerchant = r.merchant.toLowerCase().contains(query);
        final matchesNotes = r.notes?.toLowerCase().contains(query) ?? false;
        final matchesCategory = r.category.toLowerCase().contains(query);
        final matchesItems = r.items.any((item) => item.name.toLowerCase().contains(query));

        if (!matchesMerchant && !matchesNotes && !matchesCategory && !matchesItems) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sort
    switch (_currentSort) {
      case SortOption.dateDesc:
        filtered.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.dateAsc:
        filtered.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.amountDesc:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOption.amountAsc:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case SortOption.merchantAsc:
        filtered.sort((a, b) => a.merchant.toLowerCase().compareTo(b.merchant.toLowerCase()));
        break;
    }

    return filtered;
  }

  void _showSortFilterModal() {
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
                    const Text('Sort & Filter Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Text('SORT BY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
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
                                  title: Text(sort.label),
                                  value: sort,
                                ))
                            .toList(),
                      ),
                    ),
                    const Divider(),
                    const Text('DATE PERIOD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: DateRangeFilter.values.map((df) {
                        final isSelected = _dateFilter == df;
                        return ChoiceChip(
                          label: Text(df.label),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<List<Receipt>>(
      valueListenable: StorageService.instance.receiptsNotifier,
      builder: (context, allReceipts, _) {
        final filteredReceipts = _filterAndSortReceipts(allReceipts);
        final totalAmount = filteredReceipts.fold<double>(0.0, (sum, r) => sum + r.amount);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Receipt Records'),
            actions: [
              IconButton(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort & Filter',
                onPressed: _showSortFilterModal,
              ),
              if (allReceipts.isNotEmpty)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (val) async {
                    if (val == 'clear') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Clear All Receipts'),
                          content: const Text('Are you sure you want to delete all saved receipts?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Clear All'),
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
                    const PopupMenuItem(
                      value: 'clear',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Clear All Data', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
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
                        hintText: 'Search merchant, item, note...',
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
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('All Categories'),
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
                                label: Text(cat.name),
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
                        '${filteredReceipts.length} ${filteredReceipts.length == 1 ? 'receipt' : 'receipts'}${_dateFilter != DateRangeFilter.all ? ' • ${_dateFilter.label}' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        'Total: ${CurrencyHelper.format(totalAmount)}',
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
                        title: 'No Receipts Recorded Yet',
                        message:
                            'Take a photo of your paper receipt, track items and accumulate records for instant summarization.',
                        primaryActionLabel: 'Record First Receipt',
                        onPrimaryAction: widget.onNavigateToAdd,
                      )
                    : filteredReceipts.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 48, color: Colors.grey),
                                const SizedBox(height: 12),
                                const Text('No matching receipts found', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _selectedCategory = 'all';
                                      _dateFilter = DateRangeFilter.all;
                                    });
                                  },
                                  child: const Text('Reset Search & Filters'),
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
                                      title: const Text('Delete Receipt'),
                                      content: Text('Delete receipt for "${receipt.merchant}"?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () => Navigator.of(ctx).pop(true),
                                          child: const Text('Delete'),
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
            onPressed: widget.onNavigateToAdd,
            tooltip: 'Take Photo / Add Receipt',
            child: const Icon(Icons.add_a_photo),
          ),
        );
      },
    );
  }
}
