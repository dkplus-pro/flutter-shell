import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';

/// Tap-to-scale pulse amplitude for a tapped star.
const double _pulsePeakScale = 1.25;

/// Read-only-until-tapped five-star rating bar for post-stay rating (PRD 6.3).
///
/// Shows [rating] of five stars filled in gold. When [enabled], tapping star N
/// reports [onRated] exactly once with N (1-based) and plays a scale pulse on
/// the tapped star. When [enabled] is false taps are ignored; the caller is
/// expected to flip [enabled] to false after receiving [onRated] so the choice
/// becomes final.
///
/// [semanticsLabel] describes the bar for screen readers; each star also
/// exposes a positional semantics action index.
class StarRatingBar extends StatefulWidget {
  /// Creates a five-star rating bar.
  const new({
    required this.rating,
    required this.enabled,
    required this.onRated,
    required this.semanticsLabel,
    this.size = 28,
    super.key,
  });

  /// Currently selected star count (0–5).
  final int rating;

  /// Whether taps are accepted right now.
  final bool enabled;

  /// Called with the 1-based index of the tapped star.
  final ValueChanged<int> onRated;

  /// Accessibility description of the whole bar.
  final String semanticsLabel;

  /// Edge size of each star icon.
  final double size;

  @override
  State<StarRatingBar> createState() => _StarRatingBarState();
}

class _StarRatingBarState extends State<StarRatingBar> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel,
      container: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            _TappableStar(
              index: i,
              filled: i <= widget.rating,
              enabled: widget.enabled,
              size: widget.size,
              onRated: widget.onRated,
            ),
        ],
      ),
    );
  }
}

class _TappableStar extends StatefulWidget {
  const new({
    required this.index,
    required this.filled,
    required this.enabled,
    required this.size,
    required this.onRated,
  });

  final int index;
  final bool filled;
  final bool enabled;
  final double size;
  final ValueChanged<int> onRated;

  @override
  State<_TappableStar> createState() => _TappableStarState();
}

class _TappableStarState extends State<_TappableStar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: _pulsePeakScale,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 45,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: _pulsePeakScale,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeIn)),
      weight: 55,
    ),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled) {
      return;
    }
    widget.onRated(widget.index);
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Semantics(
        button: widget.enabled,
        child: ScaleTransition(
          scale: _scale,
          child: Icon(
            widget.filled ? Icons.star : Icons.star_border,
            size: widget.size,
            color: widget.filled ? HotelColors.star : HotelColors.starEmpty,
          ),
        ),
      ),
    );
  }
}
