import 'dart:ui';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_navigation_screen.dart';
import 'services/locale_service.dart';
import 'services/storage_service.dart';
import 'services/theme_service.dart';
import 'theme/app_theme.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  await LocaleService.instance.init();
  await ThemeService.instance.init();

  // Remove any previously preloaded sample receipts to ensure a completely clean start
  final current = StorageService.instance.receiptsNotifier.value;
  final sampleIds = current.where((r) => r.id.startsWith('sample-')).map((r) => r.id).toList();
  for (final id in sampleIds) {
    await StorageService.instance.deleteReceipt(id);
  }

  runApp(const ReceiptRecordApp());
}

class ReceiptRecordApp extends StatelessWidget {
  const ReceiptRecordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleService.instance.localeNotifier,
      builder: (context, currentLocale, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.instance.themeModeNotifier,
          builder: (context, currentMode, _) {
            return MaterialApp(
              onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
              debugShowCheckedModeBanner: false,
              scrollBehavior: const AppScrollBehavior(),
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: currentMode,
              locale: currentLocale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: HomeNavigationScreen(
                themeModeNotifier: ThemeService.instance.themeModeNotifier,
              ),
            );
          },
        );
      },
    );
  }
}
