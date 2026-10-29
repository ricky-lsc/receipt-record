import 'package:flutter/material.dart';
import 'screens/home_navigation_screen.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();

  // Remove any previously preloaded sample receipts to ensure a completely clean start
  final current = StorageService.instance.receiptsNotifier.value;
  final sampleIds = current.where((r) => r.id.startsWith('sample-')).map((r) => r.id).toList();
  for (final id in sampleIds) {
    await StorageService.instance.deleteReceipt(id);
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
          title: 'Receipt Record',
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
