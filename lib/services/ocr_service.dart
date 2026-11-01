import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'receipt_parser.dart';

class OcrService {
  static final OcrService instance = OcrService._internal();
  OcrService._internal();

  /// Platform channel for Apple Vision on iOS and macOS
  static const MethodChannel _appleVisionChannel =
      MethodChannel('receipt_record/apple_vision');

  /// Scans receipt image file on-device and extracts structured receipt data
  Future<ExtractedReceiptData> scanAndExtract(String imagePath) async {
    final rawText = await recognizeText(imagePath);
    if (rawText.trim().isEmpty) {
      return const ExtractedReceiptData(rawText: '');
    }
    return ReceiptParser.parse(rawText);
  }

  /// Platform-aware on-device text recognition
  Future<String> recognizeText(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('OCR error: File does not exist at $imagePath');
        return '';
      }

      // 1. Apple Vision (iOS & macOS): Native on-device VNRecognizeTextRequest
      if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
        return await _recognizeAppleVision(imagePath);
      }

      // 2. Desktop (Linux & Windows): System Tesseract CLI if installed
      if (!kIsWeb && (Platform.isLinux || Platform.isWindows)) {
        return await _recognizeDesktopTesseract(imagePath);
      }

      // 3. Android fallback note
      if (!kIsWeb && Platform.isAndroid) {
        debugPrint(
            'OCR note: Apple Vision is active for iOS/macOS. Android OCR can be connected via cloud vision or Tesseract.');
        return '';
      }

      return '';
    } catch (e) {
      debugPrint('OCR recognition error: $e');
      return '';
    }
  }

  /// Apple Vision Framework text recognition via platform channel
  Future<String> _recognizeAppleVision(String imagePath) async {
    try {
      final String? result = await _appleVisionChannel.invokeMethod<String>(
        'recognizeText',
        {'path': imagePath},
      );
      return result ?? '';
    } on PlatformException catch (e) {
      debugPrint('Apple Vision PlatformException: ${e.message}');
      return '';
    } catch (e) {
      debugPrint('Apple Vision recognition error: $e');
      return '';
    }
  }

  /// Desktop recognition via system Tesseract binary if available
  Future<String> _recognizeDesktopTesseract(String imagePath) async {
    try {
      // Check if tesseract binary is in system PATH
      final checkCmd = Platform.isWindows ? 'where' : 'which';
      final checkResult = await Process.run(checkCmd, ['tesseract']);

      if (checkResult.exitCode == 0) {
        // Run tesseract to output text to stdout
        final result = await Process.run('tesseract', [
          imagePath,
          'stdout',
          '-l',
          'eng',
          '--psm',
          '6',
        ]);

        if (result.exitCode == 0 && result.stdout != null) {
          return result.stdout.toString();
        }
      } else {
        debugPrint(
            'Tesseract CLI not detected on desktop. On Linux, run "sudo apt install tesseract-ocr" for desktop OCR.');
      }
    } catch (e) {
      debugPrint('Desktop tesseract execution error: $e');
    }
    return '';
  }
}
