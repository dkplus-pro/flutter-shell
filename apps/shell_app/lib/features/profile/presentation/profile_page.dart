import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';

/// Profile tab placeholder: centered copy; tap anywhere shows the
/// "not available yet" toast (PRD 6.5).
class ProfilePage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _showNotAvailable(context, l10n),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 64,
                  color: HotelColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.profileCenterTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.profileCenterSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotAvailable(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.placeholderNotAvailable)));
  }
}
