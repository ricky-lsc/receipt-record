import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../models/receipt.dart';
import '../models/receipt_category.dart';
import '../models/receipt_item.dart';
import '../services/sample_data_service.dart';
import '../services/storage_service.dart';
import '../widgets/receipt_image_view.dart';

class AddEditReceiptScreen extends StatefulWidget {
  final Receipt? existingReceipt;

  const AddEditReceiptScreen({super.key, this.existingReceipt});

  @override
  State<AddEditReceiptScreen> createState() => _AddEditReceiptScreenState();
}

class _AddEditReceiptScreenState extends State<AddEditReceiptScreen> {
  final _formKey = GlobalKey<FormState>();
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();
  final _taxController = TextEditingController();
  final _tipController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'groceries';
  String _selectedPaymentMethod = 'Credit Card';
  String _currency = '\$';

  String? _imagePath;
  String? _imageBase64;
  bool _isLoading = false;

  final List<ReceiptItem> _items = [];
  bool _showAdvanced = false;

  final ImagePicker _picker = ImagePicker();

  final List<String> _commonMerchants = [
    'Trader Joe\'s',
    'Whole Foods',
    'Costco',
    'Target',
    'Walmart',
    'Starbucks',
    'Apple Store',
    'Amazon',
    'Shell Gas',
    'Chevron',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingReceipt != null) {
      final r = widget.existingReceipt!;
      _merchantController.text = r.merchant;
      _amountController.text = r.amount.toStringAsFixed(2);
      if (r.taxAmount != null) _taxController.text = r.taxAmount!.toStringAsFixed(2);
      if (r.tipAmount != null) _tipController.text = r.tipAmount!.toStringAsFixed(2);
      if (r.notes != null) _notesController.text = r.notes!;
      _selectedDate = r.date;
      _selectedCategory = r.category;
      _selectedPaymentMethod = r.paymentMethod;
      _currency = r.currency;
      _imagePath = r.imagePath;
      _imageBase64 = r.imageBase64;
      _items.addAll(r.items);
      if (r.items.isNotEmpty || r.taxAmount != null || r.notes != null) {
        _showAdvanced = true;
      }
    }
  }

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    _taxController.dispose();
    _tipController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imagePath = pickedFile.path;
          _imageBase64 = base64Encode(bytes);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Receipt image captured successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access camera/photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generateSampleReceiptImage() async {
    setState(() => _isLoading = true);
    try {
      final merchant = _merchantController.text.trim().isNotEmpty
          ? _merchantController.text.trim()
          : 'Market Square';
      final total = double.tryParse(_amountController.text) ?? 34.50;

      final sampleItems = _items.isNotEmpty
          ? _items
          : [
              const ReceiptItem(id: 's1', name: 'Artisan Bread', quantity: 1, unitPrice: 4.50),
              const ReceiptItem(id: 's2', name: 'Organic Honey', quantity: 1, unitPrice: 8.99),
              const ReceiptItem(id: 's3', name: 'Fresh Roast Coffee', quantity: 1, unitPrice: 16.00),
            ];

      final base64Img = await SampleDataService.generateReceiptImage(
        merchant: merchant,
        date: _selectedDate,
        items: sampleItems,
        total: total,
        currency: _currency,
        category: _selectedCategory,
      );

      setState(() {
        _imageBase64 = base64Img;
        _imagePath = null;
        if (_merchantController.text.isEmpty) {
          _merchantController.text = merchant;
        }
        if (_amountController.text.isEmpty) {
          _amountController.text = total.toStringAsFixed(2);
        }
        if (_items.isEmpty) {
          _items.addAll(sampleItems);
          _showAdvanced = true;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generated receipt photo added!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error generating sample image: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Add Receipt Photo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.teal),
                ),
                title: const Text('Take Photo with Camera'),
                subtitle: const Text('Use your device camera to capture receipt'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.blue),
                ),
                title: const Text('Choose from Gallery / Files'),
                subtitle: const Text('Select an existing photo from storage'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome, color: Colors.amber),
                ),
                title: const Text('Generate Simulated Receipt Photo'),
                subtitle: const Text('Render a realistic receipt photo for this entry'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _generateSampleReceiptImage();
                },
              ),
              if (_imageBase64 != null || _imagePath != null) ...[
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _imageBase64 = null;
                      _imagePath = null;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );

      setState(() {
        _selectedDate = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime?.hour ?? _selectedDate.hour,
          pickedTime?.minute ?? _selectedDate.minute,
        );
      });
    }
  }

  void _addItemDialog() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Line Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Item Name', hintText: 'e.g. Organic Milk'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Qty'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: 'Price ($_currency)'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final qty = int.tryParse(qtyCtrl.text.trim()) ?? 1;
              final price = double.tryParse(priceCtrl.text.trim()) ?? 0.0;
              if (name.isNotEmpty && price > 0) {
                setState(() {
                  _items.add(ReceiptItem(
                    id: const Uuid().v4(),
                    name: name,
                    quantity: qty,
                    unitPrice: price,
                  ));
                });
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _calculateTotalFromItems() {
    final sum = _items.fold<double>(0.0, (acc, item) => acc + item.totalPrice);
    final tax = double.tryParse(_taxController.text) ?? 0.0;
    final tip = double.tryParse(_tipController.text) ?? 0.0;
    final total = sum + tax + tip;
    setState(() {
      _amountController.text = total.toStringAsFixed(2);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updated amount to $_currency${total.toStringAsFixed(2)} from items')),
    );
  }

  Future<void> _saveReceipt() async {
    if (!_formKey.currentState!.validate()) return;

    final merchant = _merchantController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    final tax = double.tryParse(_taxController.text.trim());
    final tip = double.tryParse(_tipController.text.trim());
    final notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final receipt = Receipt(
      id: widget.existingReceipt?.id ?? const Uuid().v4(),
      merchant: merchant,
      amount: amount,
      currency: _currency,
      date: _selectedDate,
      category: _selectedCategory,
      paymentMethod: _selectedPaymentMethod,
      taxAmount: tax,
      tipAmount: tip,
      notes: notes,
      imagePath: _imagePath,
      imageBase64: _imageBase64,
      items: _items,
      createdAt: widget.existingReceipt?.createdAt ?? now,
      updatedAt: now,
    );

    await StorageService.instance.saveReceipt(receipt);

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop(receipt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.existingReceipt != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Receipt' : 'Record Receipt'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveReceipt,
              icon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check, size: 18),
              label: Text(isEditing ? 'Update' : 'Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Receipt Image Section Card
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _showImageSourceDialog,
                child: Container(
                  height: 190,
                  width: double.infinity,
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                  child: (_imageBase64 != null || _imagePath != null)
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            ReceiptImageView(
                              imageBase64: _imageBase64,
                              imagePath: _imagePath,
                              fit: BoxFit.contain,
                              enableZoomOnTap: false,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.4),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.6),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.photo_camera, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text('Receipt Attached', style: TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12,
                              left: 12,
                              right: 12,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: _showImageSourceDialog,
                                    icon: const Icon(Icons.refresh, size: 16),
                                    label: const Text('Change Photo'),
                                  ),
                                  IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red.withValues(alpha: 0.7),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _imageBase64 = null;
                                        _imagePath = null;
                                      });
                                    },
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.add_a_photo,
                                size: 36,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Take Photo or Upload Receipt',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Camera, gallery, or generate sample',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Amount Field Banner
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL AMOUNT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Currency Selector Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _currency,
                              items: const [
                                DropdownMenuItem(value: '\$', child: Text('\$ USD')),
                                DropdownMenuItem(value: '€', child: Text('€ EUR')),
                                DropdownMenuItem(value: '£', child: Text('£ GBP')),
                                DropdownMenuItem(value: '¥', child: Text('¥ JPY')),
                                DropdownMenuItem(value: 'CA\$', child: Text('CA\$ CAD')),
                                DropdownMenuItem(value: 'A\$', child: Text('A\$ AUD')),
                              ],
                              onChanged: (val) {
                                if (val != null) setState(() => _currency = val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                            decoration: const InputDecoration(
                              hintText: '0.00',
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter amount';
                              }
                              final num = double.tryParse(value.trim());
                              if (num == null || num <= 0) {
                                return 'Enter a valid amount > 0';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Merchant Field & Suggestions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _merchantController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Merchant / Store Name',
                        hintText: 'e.g. Costco, Trader Joe\'s, Shell',
                        prefixIcon: Icon(Icons.storefront),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter merchant name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _commonMerchants.map((merchant) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              label: Text(merchant, style: const TextStyle(fontSize: 12)),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                _merchantController.text = merchant;
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date & Payment Method Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Date & Time Picker Tile
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.calendar_today, color: Colors.blue, size: 20),
                      ),
                      title: const Text('Date & Time', style: TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(DateFormat('EEEE, MMM d, yyyy • h:mm a').format(_selectedDate)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectDate,
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    // Payment Method Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPaymentMethod,
                      decoration: const InputDecoration(
                        labelText: 'Payment Method',
                        prefixIcon: Icon(Icons.payment),
                      ),
                      items: PaymentMethod.values.map((method) {
                        return DropdownMenuItem(
                          value: method.label,
                          child: Row(
                            children: [
                              Icon(method.icon, size: 18),
                              const SizedBox(width: 8),
                              Text(method.label),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPaymentMethod = val);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Selection Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CATEGORY',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ReceiptCategory.defaults.map((cat) {
                        final isSelected = _selectedCategory.toLowerCase() == cat.id.toLowerCase();
                        return FilterChip(
                          selected: isSelected,
                          avatar: Icon(
                            cat.icon,
                            size: 16,
                            color: isSelected ? Colors.white : cat.color,
                          ),
                          label: Text(
                            cat.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : null,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          selectedColor: cat.color,
                          checkmarkColor: Colors.white,
                          onSelected: (_) {
                            setState(() => _selectedCategory = cat.id);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Advanced / Optional Details (Items, Tax, Tip, Notes)
            Card(
              child: Theme(
                data: theme.copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: _showAdvanced,
                  onExpansionChanged: (exp) => setState(() => _showAdvanced = exp),
                  leading: const Icon(Icons.tune),
                  title: const Text(
                    'Optional Details & Line Items',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _items.isNotEmpty
                        ? '${_items.length} items added'
                        : 'Tax, tip, itemized breakdown, notes',
                    style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _taxController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Tax ($_currency)',
                                    hintText: '0.00',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  controller: _tipController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: InputDecoration(
                                    labelText: 'Tip ($_currency)',
                                    hintText: '0.00',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Line Items Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Line Items',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              TextButton.icon(
                                onPressed: _addItemDialog,
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text('Add Item'),
                              ),
                            ],
                          ),
                          if (_items.isNotEmpty) ...[
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _items.length,
                              separatorBuilder: (_, _) => const Divider(height: 8),
                              itemBuilder: (context, idx) {
                                final item = _items[idx];
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  subtitle: Text('Qty ${item.quantity} × $_currency${item.unitPrice.toStringAsFixed(2)}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '$_currency${item.totalPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 16, color: Colors.red),
                                        onPressed: () {
                                          setState(() => _items.removeAt(idx));
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _calculateTotalFromItems,
                                icon: const Icon(Icons.calculate, size: 16),
                                label: const Text('Update Total from Items'),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          // Notes Field
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Notes / Remarks',
                              hintText: 'e.g. Business lunch with client, warranty info',
                              alignLabelWithHint: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveReceipt,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        isEditing ? 'Update Receipt' : 'Save Receipt Record',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
