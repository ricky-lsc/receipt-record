import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class LocaleService {
  static final LocaleService instance = LocaleService._internal();
  LocaleService._internal();

  static const String _prefLocaleKey = 'app_locale_selection';

  static const Locale localeEnglish = Locale('en');
  static const Locale localeSimplifiedChinese =
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');
  static const Locale localeTraditionalChinese =
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant');

  final ValueNotifier<Locale?> localeNotifier = ValueNotifier<Locale?>(null);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefLocaleKey);
      if (code == 'en') {
        localeNotifier.value = localeEnglish;
      } else if (code == 'zh_Hans') {
        localeNotifier.value = localeSimplifiedChinese;
      } else if (code == 'zh_Hant') {
        localeNotifier.value = localeTraditionalChinese;
      } else {
        localeNotifier.value = null; // Follow system
      }
    } catch (e) {
      debugPrint('LocaleService init warning: $e');
      localeNotifier.value = null;
    }
  }

  Future<void> setLocale(Locale? locale) async {
    localeNotifier.value = locale;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (locale == null) {
        await prefs.setString(_prefLocaleKey, 'system');
      } else if (locale.languageCode == 'en') {
        await prefs.setString(_prefLocaleKey, 'en');
      } else if (locale.languageCode == 'zh') {
        if (locale.scriptCode == 'Hant' || locale.countryCode == 'TW' || locale.countryCode == 'HK') {
          await prefs.setString(_prefLocaleKey, 'zh_Hant');
        } else {
          await prefs.setString(_prefLocaleKey, 'zh_Hans');
        }
      }
    } catch (e) {
      debugPrint('LocaleService save warning: $e');
    }
  }

  /// Maps category IDs to localized display name
  static String getCategoryName(String categoryId, AppLocalizations l10n) {
    switch (categoryId.toLowerCase()) {
      case 'all':
        return l10n.categoryAll;
      case 'groceries':
        return l10n.categoryGroceries;
      case 'dining':
        return l10n.categoryDining;
      case 'transport':
        return l10n.categoryTransport;
      case 'shopping':
        return l10n.categoryShopping;
      case 'entertainment':
        return l10n.categoryEntertainment;
      case 'utilities':
        return l10n.categoryUtilities;
      case 'healthcare':
        return l10n.categoryHealthcare;
      case 'travel':
        return l10n.categoryTravel;
      case 'office':
        return l10n.categoryOffice;
      case 'other':
      default:
        return l10n.categoryOther;
    }
  }

  /// Maps payment method identifiers/labels to localized display name
  static String getPaymentMethodName(String paymentMethod, AppLocalizations l10n) {
    final lower = paymentMethod.toLowerCase();
    if (lower.contains('credit')) {
      return l10n.paymentCreditCard;
    } else if (lower.contains('debit')) {
      return l10n.paymentDebitCard;
    } else if (lower.contains('cash')) {
      return l10n.paymentCash;
    } else if (lower.contains('digital') || lower.contains('wallet') || lower.contains('pay')) {
      return l10n.paymentDigitalWallet;
    } else if (lower.contains('bank') || lower.contains('transfer')) {
      return l10n.paymentBankTransfer;
    }
    return l10n.paymentOther;
  }
}
