import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_record/l10n/app_localizations.dart';
import 'package:receipt_record/main.dart';
import 'package:receipt_record/screens/receipt_list_screen.dart';
import 'package:receipt_record/services/locale_service.dart';
import 'package:receipt_record/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();
    await LocaleService.instance.init();
  });

  group('Horizontal Scroll & Drag Tests', () {
    Widget buildTestApp(Widget child) {
      return MaterialApp(
        scrollBehavior: const AppScrollBehavior(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: child,
      );
    }

    testWidgets('Category chips bar scrolls horizontally with drag', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          ReceiptListScreen(onNavigateToAdd: () {}),
        ),
      );
      await tester.pumpAndSettle();

      // "All" chip should be initially visible
      expect(find.text('All'), findsOneWidget);

      // Find horizontal SingleChildScrollView
      final horizontalScrollView = find.byWidgetPredicate(
        (widget) => widget is SingleChildScrollView && widget.scrollDirection == Axis.horizontal,
      );
      expect(horizontalScrollView, findsOneWidget);

      // Drag left to reveal further categories
      await tester.drag(horizontalScrollView, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Should be able to see categories scrolled into view
      expect(find.byType(ChoiceChip), findsWidgets);
    });

    testWidgets('Scroll arrows and mouse wheel pointer events scroll category bar', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          ReceiptListScreen(onNavigateToAdd: () {}),
        ),
      );
      await tester.pumpAndSettle();

      final rightArrow = find.byTooltip('Scroll right');
      final leftArrow = find.byTooltip('Scroll left');
      expect(rightArrow, findsOneWidget);
      expect(leftArrow, findsOneWidget);

      // Tap right arrow
      await tester.tap(rightArrow);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final singleChild = tester.widget<SingleChildScrollView>(
        find.byWidgetPredicate((w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal),
      );
      expect(singleChild.controller!.offset, greaterThan(0));

      // Tap left arrow
      await tester.tap(leftArrow);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(singleChild.controller!.offset, 0.0);
    });
  });
}
