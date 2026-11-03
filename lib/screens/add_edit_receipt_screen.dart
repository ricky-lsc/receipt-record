import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../l10n/app_localizations.dart';
import '../models/receipt.dart';
import '../models/receipt_category.dart';
import '../models/receipt_item.dart';
import '../models/receipt_split.dart';
import '../services/currency_service.dart';
import '../services/glm_receipt_service.dart';
import '../services/locale_service.dart';
import '../services/sample_data_service.dart';
import '../services/storage_service.dart';
import '../utils/currency_helper.dart';
import '../widgets/cloud_ai_settings_dialog.dart';
import '../widgets/receipt_image_view.dart';
import '../widgets/split_bill_dialog.dart';

class AddEditReceiptScreen extends StatefulWidget {
  final Receipt? existingReceipt;
  final String? initialImagePath;

  const AddEditReceiptScreen({
    super.key,
    this.existingReceipt,
    this.initialImagePath,
  });

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
  String _currency = 'USD';
  String _baseCurrency = 'USD';
  double? _exchangeRate;
  double? _convertedAmount;
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _convertedAmountController = TextEditingController();
  bool _isFetchingRate = false;

  String? _imagePath;
  String? _imageBase64;
  bool _isLoading = false;
  bool _hasAiKey = false;
  bool _isAiExtracting = false;
  String? _rawOcrText;

  final List<ReceiptItem> _items = [];
  ReceiptSplit? _split;
  bool _showAdvanced = false;

  final ImagePicker _picker = ImagePicker();

  final List<String> _commonMerchants = [
    'Costco',
    'Trader Joe\'s',
    'Target',
    'Whole Foods',
    'Starbucks',
    'Walmart',
    'Amazon',
    'Shell',
    'CVS Pharmacy',
    'Home Depot',
  ];

  @override
  void initState() {
    super.initState();
    _checkAiKeyAvailability();
    _baseCurrency = CurrencyService.instance.defaultCurrencyNotifier.value;
    _currency = widget.existingReceipt?.currency ?? _baseCurrency;
    _amountController.addListener(_recalculateConvertedAmount);

    if (widget.initialImagePath != null && widget.initialImagePath!.isNotEmpty) {
      _imagePath = widget.initialImagePath;
      _loadInitialImageBytes(widget.initialImagePath!);
    }
    if (widget.existingReceipt != null) {
      final r = widget.existingReceipt!;
      _merchantController.text = r.merchant;
      _amountController.text = r.amount.toStringAsFixed(2);
      _currency = r.currency;
      _selectedDate = r.date;
      _selectedCategory = r.category;
      _selectedPaymentMethod = r.paymentMethod;
      _imagePath = r.imagePath;
      _imageBase64 = r.imageBase64;
      _baseCurrency = r.baseCurrency ?? _baseCurrency;
      _exchangeRate = r.exchangeRate;
      _convertedAmount = r.convertedAmount;
      _split = r.split;
      if (_exchangeRate != null) {
        _rateController.text = _exchangeRate!.toString();
      }
      if (_convertedAmount != null) {
        _convertedAmountController.text = _convertedAmount!.toStringAsFixed(2);
      }
      if (r.taxAmount != null) _taxController.text = r.taxAmount!.toStringAsFixed(2);
      if (r.tipAmount != null) _tipController.text = r.tipAmount!.toStringAsFixed(2);
      if (r.notes != null) _notesController.text = r.notes!;
      _items.addAll(r.items);

      if (_items.isNotEmpty || r.taxAmount != null || r.tipAmount != null || r.notes != null || r.isForeignCurrency || r.isSplit) {
        _showAdvanced = true;
      }
    }
  }

  Future<void> _openSplitDialog() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount > 0 first')),
      );
      return;
    }
    final result = await SplitBillDialog.show(
      context,
      totalAmount: amount,
      currency: _currency,
      initialSplit: _split,
    );
    if (result != null && mounted) {
      setState(() {
        _split = result.participants.length > 1 ? result : null;
      });
    }
  }

  Future<void> _loadInitialImageBytes(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (mounted) {
          setState(() {
            _imageBase64 = base64Encode(bytes);
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading initial image bytes: $e');
    }
  }

  Future<void> _checkAiKeyAvailability() async {
    final hasKey = await GlmReceiptService.instance.hasApiKey();
    if (mounted) {
      setState(() {
        _hasAiKey = hasKey;
      });
    }
  }

  Future<void> _onCurrencyChanged(String newCurrency) async {
    setState(() => _currency = newCurrency);
    if (newCurrency == _baseCurrency) {
      setState(() {
        _exchangeRate = 1.0;
        _convertedAmount = null;
        _rateController.clear();
        _convertedAmountController.clear();
      });
      return;
    }

    setState(() => _isFetchingRate = true);
    final rate = await CurrencyService.instance.getExchangeRate(
      from: newCurrency,
      to: _baseCurrency,
    );
    if (!mounted) return;
    setState(() {
      _isFetchingRate = false;
      _exchangeRate = rate;
      _rateController.text = rate.toStringAsFixed(rate < 0.01 ? 6 : 4);
      _recalculateConvertedAmount();
    });
  }

  void _recalculateConvertedAmount() {
    if (_currency == _baseCurrency) return;
    final orig = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (_exchangeRate != null && _exchangeRate! > 0) {
      final converted = orig * _exchangeRate!;
      _convertedAmount = converted;
      _convertedAmountController.text = converted.toStringAsFixed(2);
    }
  }

  void _onRateChanged(String val) {
    final r = double.tryParse(val.trim());
    if (r != null && r > 0) {
      _exchangeRate = r;
      final orig = double.tryParse(_amountController.text.trim()) ?? 0.0;
      final converted = orig * r;
      _convertedAmount = converted;
      _convertedAmountController.text = converted.toStringAsFixed(2);
    }
  }

  void _onConvertedAmountChanged(String val) {
    final conv = double.tryParse(val.trim());
    final orig = double.tryParse(_amountController.text.trim()) ?? 0.0;
    if (conv != null && conv > 0 && orig > 0) {
      _convertedAmount = conv;
      final newRate = conv / orig;
      _exchangeRate = newRate;
      _rateController.text = newRate.toStringAsFixed(newRate < 0.01 ? 6 : 4);
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_recalculateConvertedAmount);
    _merchantController.dispose();
    _amountController.dispose();
    _rateController.dispose();
    _convertedAmountController.dispose();
    _taxController.dispose();
    _tipController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final l10n = AppLocalizations.of(context);
    final isDesktop = !kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

    if (source == ImageSource.camera && isDesktop) {
      final selectFile = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.cameraNotAvailable),
          content: Text(l10n.cameraNotAvailableDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.chooseFromFiles),
            ),
          ],
        ),
      );
      if (selectFile == true && mounted) {
        _pickImage(ImageSource.gallery);
      }
      return;
    }

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
          _rawOcrText = null;
        });

        if (mounted && _hasAiKey) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.photoAttachedTip),
              action: SnackBarAction(
                label: l10n.aiExtract,
                textColor: Colors.tealAccent,
                onPressed: () => _runAiExtraction(pickedFile.path),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (source == ImageSource.camera) {
          final selectFile = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.cameraNotAvailable),
              content: Text(l10n.cameraNotAvailableDesc),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(l10n.chooseFromFiles),
                ),
              ],
            ),
          );
          if (selectFile == true && mounted) {
            _pickImage(ImageSource.gallery);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not access photo: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _runAiExtraction([String? path]) async {
    final l10n = AppLocalizations.of(context);
    final glm = GlmReceiptService.instance;
    final hasKey = await glm.hasApiKey();

    if (!hasKey) {
      if (!mounted) return;
      final shouldConfigure = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF0F766E)),
              const SizedBox(width: 8),
              Text(l10n.configureCloudAiTitle),
            ],
          ),
          content: Text(l10n.configureCloudAiDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              icon: const Icon(Icons.vpn_key, size: 16),
              label: Text(l10n.configureKey),
            ),
          ],
        ),
      );

      if (shouldConfigure == true && mounted) {
        final saved = await CloudAiSettingsDialog.show(context);
        await _checkAiKeyAvailability();
        if (saved == true && mounted && await glm.hasApiKey()) {
          // Key was saved, proceed with extraction
        } else {
          return;
        }
      } else {
        return;
      }
    }

    final targetPath = path ?? _imagePath;
    if (targetPath == null && (_imageBase64 == null || _imageBase64!.isEmpty)) {
      return;
    }

    setState(() {
      _isAiExtracting = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Text(l10n.extractingWithAi),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    try {
      final extracted = await glm.extractReceipt(
        imagePath: targetPath,
        base64Image: _imageBase64,
      );
      _rawOcrText = extracted.rawText;

      if (!mounted) return;

      bool anyFieldUpdated = false;

      setState(() {
        if (extracted.merchant != null && extracted.merchant!.isNotEmpty) {
          _merchantController.text = extracted.merchant!;
          anyFieldUpdated = true;
        }
        if (extracted.totalAmount != null && extracted.totalAmount! > 0) {
          _amountController.text = extracted.totalAmount!.toStringAsFixed(2);
          anyFieldUpdated = true;
        }
        if (extracted.taxAmount != null && extracted.taxAmount! > 0) {
          _taxController.text = extracted.taxAmount!.toStringAsFixed(2);
          _showAdvanced = true;
          anyFieldUpdated = true;
        }
        if (extracted.tipAmount != null && extracted.tipAmount! > 0) {
          _tipController.text = extracted.tipAmount!.toStringAsFixed(2);
          _showAdvanced = true;
          anyFieldUpdated = true;
        }
        if (extracted.date != null) {
          _selectedDate = extracted.date!;
          anyFieldUpdated = true;
        }
        if (extracted.category != null && extracted.category != 'other') {
          _selectedCategory = extracted.category!;
        }
        if (extracted.items.isNotEmpty) {
          _items.clear();
          _items.addAll(extracted.items);
          _showAdvanced = true;
          anyFieldUpdated = true;
        }
      });

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      if (anyFieldUpdated) {
        final itemCount = extracted.items.length;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF0F766E),
            content: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${l10n.dataExtracted}: ${extracted.merchant ?? 'Receipt'}${itemCount > 0 ? ' ($itemCount)' : ''} • $_currency${extracted.totalAmount?.toStringAsFixed(2) ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            action: (_rawOcrText != null && _rawOcrText!.isNotEmpty)
                ? SnackBarAction(
                    label: l10n.viewRaw,
                    textColor: Colors.white,
                    onPressed: _showRawOcrDialog,
                  )
                : null,
            duration: const Duration(seconds: 4),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noReceiptDataDetected),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('GLM AI extraction error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.deepOrange,
            content: Text('${l10n.dataExtracted} error: $e'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAiExtracting = false;
        });
      }
    }
  }

  void _showRawOcrDialog() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (_rawOcrText == null || _rawOcrText!.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.document_scanner, size: 20),
            const SizedBox(width: 8),
            Text(l10n.scannedText),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              _rawOcrText!,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  Future<void> _generateSampleReceiptImage() async {
    final l10n = AppLocalizations.of(context);
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
          SnackBar(
            content: Text(l10n.receiptAttached),
            duration: const Duration(seconds: 2),
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
    final l10n = AppLocalizations.of(context);
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  l10n.takePhotoOrUpload,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                title: Text(l10n.takePhoto),
                subtitle: Text(l10n.photoUploadSubtitle),
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
                title: Text(l10n.chooseFromGallery),
                subtitle: Text(l10n.photoUploadSubtitle),
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
                title: Text(l10n.generateSamplePhoto),
                subtitle: Text(l10n.photoUploadSubtitle),
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
                  title: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
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
    final l10n = AppLocalizations.of(context);
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.addItem),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.itemName, hintText: 'e.g. Organic Milk'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: l10n.quantity),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: priceCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: '${l10n.unitPrice} ($_currency)'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
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
            child: Text(l10n.addItem),
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
      SnackBar(content: Text('$_currency${total.toStringAsFixed(2)}')),
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
    final receiptId = widget.existingReceipt?.id ?? const Uuid().v4();

    // Persist receipt image to configured storage folder
    String? finalImagePath = _imagePath;
    if (_imageBase64 != null || _imagePath != null) {
      final savedPath = await StorageService.instance.saveReceiptImageFile(
        receiptId: receiptId,
        sourcePath: _imagePath,
        base64Data: _imageBase64,
        merchant: merchant,
        date: _selectedDate,
      );
      if (savedPath != null) {
        finalImagePath = savedPath;
      }
    }

    final receipt = Receipt(
      id: receiptId,
      merchant: merchant,
      amount: amount,
      currency: _currency,
      date: _selectedDate,
      category: _selectedCategory,
      paymentMethod: _selectedPaymentMethod,
      taxAmount: tax,
      tipAmount: tip,
      notes: notes,
      imagePath: finalImagePath,
      imageBase64: _imageBase64,
      items: _items,
      split: _split,
      baseCurrency: _baseCurrency,
      exchangeRate: _currency == _baseCurrency ? 1.0 : _exchangeRate,
      convertedAmount: _currency == _baseCurrency ? amount : _convertedAmount,
      createdAt: widget.existingReceipt?.createdAt ?? now,
      updatedAt: now,
    );

    await StorageService.instance.saveReceipt(receipt);

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() => _isLoading = false);
      Navigator.of(context).pop(receipt);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEditing = widget.existingReceipt != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editReceipt : l10n.recordReceipt),
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
              label: Text(isEditing ? l10n.update : l10n.save),
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
                            if (_rawOcrText != null && _rawOcrText!.isNotEmpty)
                              Positioned(
                                top: 10,
                                left: 10,
                                child: InkWell(
                                  onTap: _showRawOcrDialog,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F766E).withValues(alpha: 0.85),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _rawOcrText!.contains('"merchant"') || _rawOcrText!.contains('GLM')
                                              ? Icons.auto_awesome
                                              : Icons.check,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(l10n.dataExtracted, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
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
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.photo_camera, color: Colors.white, size: 14),
                                    const SizedBox(width: 4),
                                    Text(l10n.receiptAttached, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            if (_isAiExtracting)
                              Container(
                                color: Colors.black54,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const CircularProgressIndicator(color: Colors.white),
                                      const SizedBox(height: 10),
                                      Text(
                                        l10n.extractingWithAi,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
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
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          backgroundColor: Colors.black54,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: _showImageSourceDialog,
                                        icon: const Icon(Icons.refresh, size: 16),
                                        label: Text(l10n.changePhoto),
                                      ),
                                      if (_hasAiKey) ...[
                                        const SizedBox(width: 6),
                                        TextButton.icon(
                                          style: TextButton.styleFrom(
                                            backgroundColor: const Color(0xFF0F766E),
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: _isAiExtracting
                                              ? null
                                              : () => _runAiExtraction(),
                                          icon: const Icon(Icons.auto_awesome, size: 16),
                                          label: Text(l10n.aiExtract),
                                        ),
                                      ],
                                    ],
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
                                        _rawOcrText = null;
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
                            Text(
                              l10n.takePhotoOrUpload,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.photoUploadSubtitle,
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
                      l10n.totalAmount,
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
                              items: CurrencyService.supportedCurrencies.map((c) {
                                return DropdownMenuItem(
                                  value: c.code,
                                  child: Text('${c.flag} ${c.code} (${c.symbol})'),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) _onCurrencyChanged(val);
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
                                return l10n.merchantRequired;
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
                    if (_currency != _baseCurrency) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFF99F6E4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.currency_exchange, size: 16, color: Color(0xFF0F766E)),
                                    const SizedBox(width: 6),
                                    Text(
                                      l10n.foreignCurrencyConversion,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Color(0xFF0F766E),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_isFetchingRate)
                                  const SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F766E)),
                                  )
                                else
                                  InkWell(
                                    onTap: () => _onCurrencyChanged(_currency),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.refresh, size: 13, color: Color(0xFF0F766E)),
                                        const SizedBox(width: 4),
                                        Text(
                                          l10n.liveRateFetched,
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF0F766E)),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _rateController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: '1 $_currency = ($_baseCurrency)',
                                      labelStyle: const TextStyle(fontSize: 11),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    ),
                                    style: const TextStyle(fontSize: 13),
                                    onChanged: _onRateChanged,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: _convertedAmountController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: '${l10n.convertedTo} (${CurrencyService.instance.getSymbol(_baseCurrency)})',
                                      labelStyle: const TextStyle(fontSize: 11),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    ),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                    onChanged: _onConvertedAmountChanged,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
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
                      decoration: InputDecoration(
                        labelText: l10n.merchantName,
                        hintText: l10n.merchantPlaceholder,
                        prefixIcon: const Icon(Icons.storefront),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.merchantRequired;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
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
                      title: Text(l10n.date, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(DateFormat('yyyy-MM-dd • h:mm a').format(_selectedDate)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: _selectDate,
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    // Payment Method Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedPaymentMethod,
                      decoration: InputDecoration(
                        labelText: l10n.paymentMethod,
                        prefixIcon: const Icon(Icons.payment),
                      ),
                      items: PaymentMethod.values.map((method) {
                        return DropdownMenuItem(
                          value: method.label,
                          child: Row(
                            children: [
                              Icon(method.icon, size: 18),
                              const SizedBox(width: 8),
                              Text(LocaleService.getPaymentMethodName(method.label, l10n)),
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
                      l10n.category,
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
                            LocaleService.getCategoryName(cat.id, l10n),
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

            // Split Bill Section Card
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.call_split, color: Color(0xFF0F766E), size: 18),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.splitBillTitle,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                Text(
                                  _split != null && _split!.participants.length > 1
                                      ? '${_split!.participants.length} (${l10n.splitBill})'
                                      : l10n.numberOfPeople,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (_split != null && _split!.participants.length > 1)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                tooltip: l10n.edit,
                                visualDensity: VisualDensity.compact,
                                onPressed: _openSplitDialog,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                tooltip: l10n.clearSplit,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => setState(() => _split = null),
                              ),
                            ],
                          ),
                      ],
                    ),
                    if (_split != null && _split!.participants.length > 1) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isDark ? const Color(0xFF334155) : const Color(0xFF99F6E4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${l10n.netPersonal}:',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                                Text(
                                  CurrencyHelper.formatWithCode(_split!.myShare, _currency),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F766E)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${l10n.unsettledFromFriends}:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                                Text(
                                  CurrencyHelper.formatWithCode(_split!.otherSharesTotal, _currency),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _openSplitDialog,
                        icon: const Icon(Icons.person_add_outlined, size: 16),
                        label: Text(l10n.splitBill),
                      ),
                    ],
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
                  title: Text(
                    l10n.advancedDetails,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _items.isNotEmpty
                        ? '${_items.length} ${l10n.receiptCountSuffix}'
                        : '${l10n.tax}, ${l10n.tip}, ${l10n.lineItems}, ${l10n.notes}',
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
                                    labelText: '${l10n.tax} ($_currency)',
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
                                    labelText: '${l10n.tip} ($_currency)',
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
                              Text(
                                l10n.lineItems,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              TextButton.icon(
                                onPressed: _addItemDialog,
                                icon: const Icon(Icons.add, size: 16),
                                label: Text(l10n.addItem),
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
                                  subtitle: Text('${l10n.quantity} ${item.quantity} × $_currency${item.unitPrice.toStringAsFixed(2)}'),
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
                                label: Text(l10n.subtotal),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          // Notes Field
                          TextFormField(
                            controller: _notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: l10n.notes,
                              hintText: l10n.notesPlaceholder,
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
                        isEditing ? l10n.update : l10n.save,
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
