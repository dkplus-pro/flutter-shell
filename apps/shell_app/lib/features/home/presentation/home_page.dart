import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttershell/core/router/app_router.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Home tab placeholder: centered copy, tap anywhere shows the
/// "not available yet" toast, and the bridge demo stays reachable (PRD 4/6.5).
class HomePage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
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
                  Icons.home_outlined,
                  size: 64,
                  color: HotelColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  l10n.helloWorld,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.helloSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppPrimaryButton(
                  label: l10n.openBridgeDemo,
                  onPressed: () => context.push(AppRoutes.bridgeDemo),
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
