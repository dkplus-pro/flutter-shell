import 'package:flutter/material.dart';
import 'package:fluttershell/core/shell/app_bottom_nav_bar.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

/// Bottom navigation shell hosting the three main tabs. The stock
/// `NavigationBar` was replaced by the self-drawn [AppBottomNavBar]
/// (docs/06 §3.1); the centered service tab renders its selected icon
/// inside the 44dp purple circle.
class AppShellPage extends StatelessWidget {
  const AppShellPage({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: [
          AppBottomNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: l10n.homeTab,
          ),
          AppBottomNavItem(
            icon: Icons.headset_mic_outlined,
            selectedIcon: Icons.headset_mic,
            label: l10n.serviceTab,
            circleWhenSelected: true,
          ),
          AppBottomNavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: l10n.profileTab,
          ),
        ],
      ),
    );
  }
}
