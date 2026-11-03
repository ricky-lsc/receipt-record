import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../widgets/quick_receipt_action_sheet.dart';
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

    final List<Widget> screens = [
      ReceiptListScreen(
        onNavigateToAdd: _navigateToAddReceipt,
        themeModeNotifier: widget.themeModeNotifier,
      ),
      SummaryScreen(
        onNavigateToAdd: _navigateToAddReceipt,
        onNavigateToExport: _navigateToExport,
        themeModeNotifier: widget.themeModeNotifier,
      ),
      const ExportScreen(),
    ];

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: screens[_currentIndex],
        ),
      ),
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
