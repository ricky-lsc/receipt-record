import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'receipt_parser.dart';

class OcrService {
  static final OcrService instance = OcrService._internal();
  OcrService._internal();

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

      // 1. Mobile (Android & iOS): Google ML Kit On-Device Vision
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        return await _recognizeMobile(imagePath);
      }

      // 2. Desktop (Linux, macOS, Windows): Tesseract CLI if installed
      if (!kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows)) {
        return await _recognizeDesktopTesseract(imagePath);
      }

      return '';
    } catch (e) {
      debugPrint('OCR recognition error: $e');
      return '';
    }
  }

  /// Mobile recognition via Google ML Kit Text Recognition
  Future<String> _recognizeMobile(String imagePath) async {
    TextRecognizer? textRecognizer;
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('Google ML Kit error: $e');
      return '';
    } finally {
      textRecognizer?.close();
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
