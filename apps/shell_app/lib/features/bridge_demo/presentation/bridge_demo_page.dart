import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fluttershell/features/bridge_demo/application/bridge_demo_providers.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';

/// Bridge demo page covering the three v0 links: system info method call,
/// 1Hz native ticker and the native screen round-trip.
class BridgeDemoPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    ref.listen(nativeScreenResultsProvider, (previous, next) {
      final result = next.value;
      if (result == null || !context.mounted) {
        return;
      }
      final text = result.confirmed
          ? l10n.nativeResultConfirmed(result.message)
          : l10n.nativeResultCancelled(result.message);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bridgeDemoTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [_SystemInfoCard(), _TickerCard(), _NativeScreenCard()],
      ),
    );
  }
}

class _SystemInfoCard extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final info = ref.watch(systemInfoProvider);
    return AppSectionCard(
      title: l10n.systemInfoTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          info.when(
            data: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'platform', value: data.platform),
                _InfoRow(label: 'osVersion', value: data.osVersion),
                _InfoRow(label: 'deviceModel', value: data.deviceModel),
                _InfoRow(label: 'manufacturer', value: data.manufacturer),
                _InfoRow(label: 'appVersion', value: data.appVersion),
                _InfoRow(label: 'buildNumber', value: data.buildNumber),
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.sm),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Text(
              '${l10n.errorTitle}: $error',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          AppPrimaryButton(
            label: l10n.refresh,
            onPressed: () => ref.invalidate(systemInfoProvider),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const new({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

/// High-frequency ticker is watched in an isolated [Consumer] so only the
/// count text rebuilds, not the page.
class _TickerCard extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return AppSectionCard(
      title: l10n.tickerTitle,
      child: Consumer(
        builder: (context, ref, _) {
          final ticks = ref.watch(tickCountProvider);
          return ticks.when(
            data: (count) => Text(
              l10n.ticksValue(count),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            loading: () => const SizedBox(height: 32),
            error: (error, _) => Text(
              '${l10n.errorTitle}: $error',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        },
      ),
    );
  }
}

class _NativeScreenCard extends ConsumerStatefulWidget {
  const new();

  @override
  ConsumerState<_NativeScreenCard> createState() => _NativeScreenCardState();
}

class _NativeScreenCardState extends ConsumerState<_NativeScreenCard> {
  bool _launching = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppSectionCard(
      title: l10n.nativeScreenTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPrimaryButton(
            label: l10n.openNativeScreen,
            onPressed: _launching ? null : () => _openNativeScreen(l10n),
          ),
        ],
      ),
    );
  }

  Future<void> _openNativeScreen(AppLocalizations l10n) async {
    setState(() => _launching = true);
    try {
      await ref.read(
        openNativeScreenProvider(
          title: l10n.nativeScreenTitle,
          message: l10n.helloSubtitle,
        ).future,
      );
    } on Exception catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.errorTitle}: $error')));
      }
    } finally {
      if (mounted) {
        setState(() => _launching = false);
      }
    }
  }
}
