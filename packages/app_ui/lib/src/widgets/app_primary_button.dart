import 'package:flutter/material.dart';

/// Filled primary button with an accessible 48dp minimum height.
///
/// Accepts data and callbacks only; labels come from the caller (l10n).
class AppPrimaryButton extends StatelessWidget {
  const new({required this.label, this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
        child: Text(label),
      ),
    );
  }
}
