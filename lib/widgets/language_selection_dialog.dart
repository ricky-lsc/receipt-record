import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/locale_service.dart';

class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const LanguageSelectionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = LocaleService.instance.localeNotifier.value;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          const Icon(Icons.language, color: Color(0xFF0F766E), size: 24),
          const SizedBox(width: 10),
          Text(l10n.chooseLanguage),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOption(
            context: context,
            title: l10n.followSystem,
            subtitle: 'System default',
            isSelected: currentLocale == null,
            onTap: () async {
              await LocaleService.instance.setLocale(null);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          const Divider(height: 1),
          _buildOption(
            context: context,
            title: l10n.english,
            subtitle: 'English (US)',
            isSelected: currentLocale?.languageCode == 'en',
            onTap: () async {
              await LocaleService.instance.setLocale(LocaleService.localeEnglish);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          const Divider(height: 1),
          _buildOption(
            context: context,
            title: l10n.traditionalChinese,
            subtitle: 'Traditional Chinese',
            isSelected: currentLocale?.languageCode == 'zh' &&
                (currentLocale?.scriptCode == 'Hant' || currentLocale?.countryCode == 'TW'),
            onTap: () async {
              await LocaleService.instance.setLocale(LocaleService.localeTraditionalChinese);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
          const Divider(height: 1),
          _buildOption(
            context: context,
            title: l10n.simplifiedChinese,
            subtitle: 'Simplified Chinese',
            isSelected: currentLocale?.languageCode == 'zh' &&
                (currentLocale?.scriptCode == 'Hans' || currentLocale?.countryCode == 'CN' || currentLocale?.scriptCode == null),
            onTap: () async {
              await LocaleService.instance.setLocale(LocaleService.localeSimplifiedChinese);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF0F766E) : null,
        ),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Color(0xFF0F766E), size: 20)
          : const Icon(Icons.radio_button_unchecked, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
