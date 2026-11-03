import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/theme_service.dart';
import '../widgets/cloud_ai_settings_dialog.dart';
import '../widgets/language_selection_dialog.dart';
import '../widgets/quick_receipt_action_sheet.dart';
import '../widgets/storage_settings_dialog.dart';
import 'export_screen.dart';
import 'receipt_list_screen.dart';
import 'summary_screen.dart';

class HomeNavigationScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeModeNotifier;

  const HomeNavigationScreen({super.key, required this.themeModeNotifier});

  @override
  State<HomeNavigationScreen> createState() => _HomeNavigationScreenState();
}

class _HomeNavigationScreenState extends State<HomeNavigationScreen> {
  int _currentIndex = 0;

  void _navigateToAddReceipt() {
    QuickReceiptActionSheet.show(context);
  }

  void _navigateToExport() {
    setState(() => _currentIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 700;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
      ReceiptListScreen(onNavigateToAdd: _navigateToAddReceipt),
      SummaryScreen(
        onNavigateToAdd: _navigateToAddReceipt,
        onNavigateToExport: _navigateToExport,
      ),
      const ExportScreen(),
    ];

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    FloatingActionButton(
                      mini: true,
                      onPressed: _navigateToAddReceipt,
                      tooltip: l10n.addReceiptTooltip,
                      child: const Icon(Icons.add_a_photo),
                    ),
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.language),
                          tooltip: l10n.chooseLanguageTooltip,
                          onPressed: () => LanguageSelectionDialog.show(context),
                        ),
                        const SizedBox(height: 6),
                        IconButton(
                          icon: const Icon(Icons.auto_awesome),
                          tooltip: l10n.cloudAiSettingsTooltip,
                          onPressed: () => CloudAiSettingsDialog.show(context),
                        ),
                        const SizedBox(height: 6),
                        IconButton(
                          icon: const Icon(Icons.folder_shared_outlined),
                          tooltip: l10n.storageSettings,
                          onPressed: () => StorageSettingsDialog.show(context),
                        ),
                        const SizedBox(height: 6),
                        IconButton(
                          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                          tooltip: l10n.toggleThemeTooltip,
                          onPressed: () {
                            ThemeService.instance.toggleTheme(isDark);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.receipt_long_outlined),
                  selectedIcon: const Icon(Icons.receipt_long),
                  label: Text(l10n.navReceipts),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.analytics_outlined),
                  selectedIcon: const Icon(Icons.analytics),
                  label: Text(l10n.navSummary),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.file_download_outlined),
                  selectedIcon: const Icon(Icons.file_download),
                  label: Text(l10n.navExport),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(child: screens[_currentIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.navReceipts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: const Icon(Icons.analytics),
            label: l10n.navSummary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.file_download_outlined),
            selectedIcon: const Icon(Icons.file_download),
            label: l10n.navExport,
          ),
        ],
      ),
    );
  }
}
