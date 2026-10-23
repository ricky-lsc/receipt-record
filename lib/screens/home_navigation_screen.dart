import 'package:flutter/material.dart';
import 'add_edit_receipt_screen.dart';
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
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddEditReceiptScreen(),
      ),
    );
  }

  void _navigateToExport() {
    setState(() => _currentIndex = 2);
  }

  @override
  Widget build(BuildContext context) {
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
                      tooltip: 'Take Photo / Add Receipt',
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
                    child: IconButton(
                      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                      tooltip: 'Toggle Theme',
                      onPressed: () {
                        widget.themeModeNotifier.value =
                            isDark ? ThemeMode.light : ThemeMode.dark;
                      },
                    ),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: Text('Receipts'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics),
                  label: Text('Summary'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.file_download_outlined),
                  selectedIcon: Icon(Icons.file_download),
                  label: Text('Export'),
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Receipts',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Summary',
          ),
          NavigationDestination(
            icon: Icon(Icons.file_download_outlined),
            selectedIcon: Icon(Icons.file_download),
            label: 'Export',
          ),
        ],
      ),
    );
  }
}
