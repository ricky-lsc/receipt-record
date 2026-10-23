import 'package:flutter/material.dart';
import 'screens/home_navigation_screen.dart';
import 'services/sample_data_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();

  // If there are no receipts stored, preload the realistic sample receipts
  // so the user immediately has data to review, summarize, and export.
  if (StorageService.instance.receiptsNotifier.value.isEmpty) {
    try {
      final samples = await SampleDataService.getPreloadedSampleReceipts();
      await StorageService.instance.importReceipts(samples);
    } catch (e) {
      debugPrint('Error loading initial sample data: $e');
    }
  }

  runApp(const ReceiptRecordApp());
}

class ReceiptRecordApp extends StatefulWidget {
  const ReceiptRecordApp({super.key});

  @override
  State<ReceiptRecordApp> createState() => _ReceiptRecordAppState();
}

class _ReceiptRecordAppState extends State<ReceiptRecordApp> {
  final ValueNotifier<ThemeMode> _themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  @override
  void dispose() {
    _themeModeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeModeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Receipt Record & Summary',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: HomeNavigationScreen(
            themeModeNotifier: _themeModeNotifier,
          ),
        );
      },
    );
  }
}
