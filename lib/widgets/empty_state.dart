import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.primaryActionLabel,
    this.onPrimaryAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFF0F766E).withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFF0F766E).withValues(alpha: 0.15),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 48,
                color: isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxFormatConstraint(maxWidth: 340),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (primaryActionLabel != null && onPrimaryAction != null)
              ElevatedButton.icon(
                onPressed: onPrimaryAction,
                icon: const Icon(Icons.add_a_photo, size: 18),
                label: Text(primaryActionLabel!),
              ),
            if (secondaryActionLabel != null && onSecondaryAction != null) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: onSecondaryAction,
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: Text(secondaryActionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class BoxFormatConstraint extends BoxConstraints {
  const BoxFormatConstraint({super.maxWidth});
}
