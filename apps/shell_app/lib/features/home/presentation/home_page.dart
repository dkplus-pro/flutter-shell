import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttershell/core/router/app_router.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Baseline home page: hello copy plus the entry to the bridge demo.
class HomePage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
    );
  }
}
