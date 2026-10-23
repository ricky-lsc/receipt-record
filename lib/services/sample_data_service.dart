import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/receipt.dart';
import '../models/receipt_item.dart';

class SampleDataService {
  /// Generates a realistic receipt PNG rendered via Canvas and encoded to base64.
  static Future<String> generateReceiptImage({
    required String merchant,
    required DateTime date,
    required List<ReceiptItem> items,
    required double total,
    required String currency,
    required String category,
  }) async {
    const double width = 380;
    final double height = 480 + (items.length * 28);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, height));

    // Background paper
    final paperPaint = Paint()..color = const Color(0xFFF9F8F6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, width, height), const Radius.circular(12)),
      paperPaint,
    );

    // Subtle paper border
    final borderPaint = Paint()
      ..color = const Color(0xFFE2DDD5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, width - 2, height - 2), const Radius.circular(12)),
      borderPaint,
    );

    // Header Accent bar
    final accentPaint = Paint()..color = const Color(0xFF0F766E);
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTWH(0, 0, width, 8),
        topLeft: const Radius.circular(12),
        topRight: const Radius.circular(12),
      ),
      accentPaint,
    );

    double currentY = 32;

    void drawText(
      String text, {
      required double y,
      double fontSize = 14,
      FontWeight fontWeight = FontWeight.normal,
      Color color = const Color(0xFF1F2937),
      TextAlign align = TextAlign.center,
      double leftPadding = 20,
      double rightPadding = 20,
    }) {
      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: 'monospace',
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: align,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(maxWidth: width - leftPadding - rightPadding);
      double x = leftPadding;
      if (align == TextAlign.center) {
        x = (width - textPainter.width) / 2;
      } else if (align == TextAlign.right) {
        x = width - rightPadding - textPainter.width;
      }
      textPainter.paint(canvas, Offset(x, y));
    }

    void drawDashedLine(double y) {
      final dashPaint = Paint()
        ..color = const Color(0xFFCBD5E1)
        ..strokeWidth = 1.2;
      double startX = 24;
      while (startX < width - 24) {
        canvas.drawLine(Offset(startX, y), Offset(startX + 6, y), dashPaint);
        startX += 10;
      }
    }

    // Merchant
    drawText(merchant.toUpperCase(), y: currentY, fontSize: 20, fontWeight: FontWeight.bold);
    currentY += 28;

    // Subtitle
    drawText('OFFICIAL RECEIPT', y: currentY, fontSize: 11, color: const Color(0xFF64748B));
    currentY += 18;

    // Date and Category
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    drawText(dateStr, y: currentY, fontSize: 11, color: const Color(0xFF64748B));
    currentY += 26;

    drawDashedLine(currentY);
    currentY += 16;

    // Column headers
    drawText('ITEM', y: currentY, fontSize: 11, fontWeight: FontWeight.bold, align: TextAlign.left, leftPadding: 24);
    drawText('QTY', y: currentY, fontSize: 11, fontWeight: FontWeight.bold, align: TextAlign.left, leftPadding: 220);
    drawText('TOTAL', y: currentY, fontSize: 11, fontWeight: FontWeight.bold, align: TextAlign.right, rightPadding: 24);
    currentY += 20;

    drawDashedLine(currentY);
    currentY += 14;

    // Items
    for (final item in items) {
      final itemName = item.name.length > 20 ? '${item.name.substring(0, 18)}..' : item.name;
      drawText(itemName, y: currentY, fontSize: 13, align: TextAlign.left, leftPadding: 24);
      drawText('x${item.quantity}', y: currentY, fontSize: 12, color: const Color(0xFF64748B), align: TextAlign.left, leftPadding: 226);
      drawText('$currency${item.totalPrice.toStringAsFixed(2)}', y: currentY, fontSize: 13, align: TextAlign.right, rightPadding: 24);
      currentY += 24;
    }

    currentY += 10;
    drawDashedLine(currentY);
    currentY += 18;

    // Total
    drawText('TOTAL AMOUNT', y: currentY, fontSize: 15, fontWeight: FontWeight.bold, align: TextAlign.left, leftPadding: 24);
    drawText('$currency${total.toStringAsFixed(2)}', y: currentY, fontSize: 19, fontWeight: FontWeight.bold, color: const Color(0xFF0F766E), align: TextAlign.right, rightPadding: 24);
    currentY += 36;

    drawDashedLine(currentY);
    currentY += 18;

    // Barcode mock
    final barcodePaint = Paint()..color = const Color(0xFF334155);
    double bx = 45;
    final barcodeWidths = [3, 1, 4, 2, 1, 3, 2, 4, 1, 2, 3, 1, 4, 2, 1, 3, 2, 1, 4, 2, 3, 1, 2, 4, 1, 3, 2];
    for (final bw in barcodeWidths) {
      canvas.drawRect(Rect.fromLTWH(bx, currentY, bw.toDouble(), 34), barcodePaint);
      bx += bw + 3;
    }
    currentY += 46;

    drawText('THANK YOU FOR YOUR PURCHASE', y: currentY, fontSize: 10, color: const Color(0xFF94A3B8));

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) return '';
    final bytes = byteData.buffer.asUint8List();
    return base64Encode(bytes);
  }

  static Future<List<Receipt>> getPreloadedSampleReceipts() async {
    final now = DateTime.now();

    final samples = [
      {
        'id': 'sample-1',
        'merchant': 'Trader Joe\'s',
        'amount': 48.65,
        'category': 'groceries',
        'paymentMethod': 'Credit Card',
        'date': now.subtract(const Duration(hours: 4)),
        'taxAmount': 3.45,
        'notes': 'Weekly groceries: organic fruits and artisan bread',
        'items': [
          const ReceiptItem(id: 'i1', name: 'Organic Bananas', quantity: 2, unitPrice: 1.49),
          const ReceiptItem(id: 'i2', name: 'Almond Milk (Unsweetened)', quantity: 2, unitPrice: 3.29),
          const ReceiptItem(id: 'i3', name: 'Sourdough Boule', quantity: 1, unitPrice: 4.99),
          const ReceiptItem(id: 'i4', name: 'Fresh Atlantic Salmon', quantity: 1, unitPrice: 16.99),
          const ReceiptItem(id: 'i5', name: 'Greek Yogurt 32oz', quantity: 2, unitPrice: 5.49),
          const ReceiptItem(id: 'i6', name: 'Dark Chocolate Bar', quantity: 2, unitPrice: 3.10),
        ],
      },
      {
        'id': 'sample-2',
        'merchant': 'Blue Bottle Coffee',
        'amount': 16.20,
        'category': 'dining',
        'paymentMethod': 'Digital Wallet',
        'date': now.subtract(const Duration(days: 1, hours: 2)),
        'taxAmount': 1.20,
        'tipAmount': 2.50,
        'notes': 'Client coffee meeting: pour over and almond croissant',
        'items': [
          const ReceiptItem(id: 'i7', name: 'Hayes Valley Espresso', quantity: 1, unitPrice: 4.75),
          const ReceiptItem(id: 'i8', name: 'Single Origin Pour Over', quantity: 1, unitPrice: 6.25),
          const ReceiptItem(id: 'i9', name: 'Almond Croissant', quantity: 1, unitPrice: 5.20),
        ],
      },
      {
        'id': 'sample-3',
        'merchant': 'Chevron Gas & Auto',
        'amount': 54.80,
        'category': 'transport',
        'paymentMethod': 'Debit Card',
        'date': now.subtract(const Duration(days: 3)),
        'taxAmount': 4.10,
        'notes': 'Full tank premium gas & windshield fluid',
        'items': [
          const ReceiptItem(id: 'i10', name: 'Premium Fuel 91 (12.2 gal)', quantity: 1, unitPrice: 50.81),
          const ReceiptItem(id: 'i11', name: 'All-Season Washer Fluid', quantity: 1, unitPrice: 3.99),
        ],
      },
      {
        'id': 'sample-4',
        'merchant': 'Apple Store',
        'amount': 129.00,
        'category': 'shopping',
        'paymentMethod': 'Credit Card',
        'date': now.subtract(const Duration(days: 6)),
        'taxAmount': 11.25,
        'notes': 'USB-C Magic Trackpad replacement for work desk',
        'items': [
          const ReceiptItem(id: 'i12', name: 'Magic Trackpad - Black', quantity: 1, unitPrice: 129.00),
        ],
      },
      {
        'id': 'sample-5',
        'merchant': 'CVS Pharmacy',
        'amount': 28.40,
        'category': 'health',
        'paymentMethod': 'Credit Card',
        'date': now.subtract(const Duration(days: 9)),
        'taxAmount': 2.15,
        'notes': 'Vitamins and first-aid supplies',
        'items': [
          const ReceiptItem(id: 'i13', name: 'Multivitamin Complex 90ct', quantity: 1, unitPrice: 18.99),
          const ReceiptItem(id: 'i14', name: 'Antibacterial Bandages', quantity: 1, unitPrice: 5.49),
          const ReceiptItem(id: 'i15', name: 'Hydrating Lip Balm', quantity: 1, unitPrice: 3.92),
        ],
      },
      {
        'id': 'sample-6',
        'merchant': 'Staples Office Supplies',
        'amount': 72.15,
        'category': 'office',
        'paymentMethod': 'Credit Card',
        'date': now.subtract(const Duration(days: 14)),
        'taxAmount': 5.80,
        'notes': 'Printer paper boxes and ergonomic gel mouse pad',
        'items': [
          const ReceiptItem(id: 'i16', name: 'Multipurpose Paper 5-ream', quantity: 2, unitPrice: 28.50),
          const ReceiptItem(id: 'i17', name: 'Gel Wrist Rest Pad', quantity: 1, unitPrice: 15.15),
        ],
      },
    ];

    final List<Receipt> receipts = [];

    for (final s in samples) {
      final merchant = s['merchant'] as String;
      final date = s['date'] as DateTime;
      final amount = s['amount'] as double;
      final category = s['category'] as String;
      final items = s['items'] as List<ReceiptItem>;

      final base64Img = await generateReceiptImage(
        merchant: merchant,
        date: date,
        items: items,
        total: amount,
        currency: '\$',
        category: category,
      );

      receipts.add(Receipt(
        id: s['id'] as String,
        merchant: merchant,
        amount: amount,
        currency: '\$',
        date: date,
        category: category,
        paymentMethod: s['paymentMethod'] as String,
        taxAmount: s['taxAmount'] as double?,
        tipAmount: s['tipAmount'] as double?,
        notes: s['notes'] as String?,
        imageBase64: base64Img,
        items: items,
        createdAt: date,
        updatedAt: date,
      ));
    }

    return receipts;
  }
}
