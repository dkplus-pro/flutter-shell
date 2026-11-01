import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// One entry of the custom bottom navigation bar.
class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.circleWhenSelected = false,
  });

  /// Unselected (outline) icon.
  final IconData icon;

  /// Selected (filled) icon.
  final IconData selectedIcon;

  /// Localized label rendered below the icon.
  final String label;

  /// When true, the selected state renders inside the 44dp purple circle
  /// (docs/06 §3.1: the centered service tab).
  final bool circleWhenSelected;
}

/// Self-drawn bottom navigation (docs/06 §3.1): white bar with a top
/// hairline; unselected items are outline grey icons with grey labels,
/// selected items are solid purple with purple labels, and items with
/// [AppBottomNavItem.circleWhenSelected] host the selected icon inside a
/// 44dp purple circle.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: HotelColors.surface,
        border: Border(
          top: BorderSide(color: HotelColors.divider, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    item: items[i],
                    selected: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? HotelColors.primary : HotelColors.textSecondary;
    final icon = Icon(
      selected ? item.selectedIcon : item.icon,
      size: 24,
      color: selected && item.circleWhenSelected ? Colors.white : color,
    );
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: HotelDimens.navCircleSize,
              width: HotelDimens.navCircleSize,
              child: Center(
                child: selected && item.circleWhenSelected
                    ? Container(
                        height: HotelDimens.navCircleSize,
                        width: HotelDimens.navCircleSize,
                        decoration: const BoxDecoration(
                          color: HotelColors.primary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: icon,
                      )
                    : icon,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: HotelTypography.navLabel.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
