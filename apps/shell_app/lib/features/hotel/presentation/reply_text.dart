import 'dart:async';

import 'package:flutter/material.dart';

/// Characters that trigger an extra pause while typing, so a scripted concierge
/// reply reads more naturally (PRD 7.3).
const String _punctuationChars = '，。！？；…、,.!?;:';

/// Typewriter-style progressive text reveal for concierge replies.
///
/// Starts from an empty string and reveals [text] one character at a time,
/// waiting [charInterval] between characters. After a punctuation character
/// from [_punctuationChars] is revealed, the next delay is multiplied by
/// [punctuationPauseFactor].
///
/// The widget is driven by a [Timer] that is cancelled in [State.dispose]; a
/// [ReplyTypewriter] removed from the tree stops typing immediately.
///
/// Constraint: the reveal always replays from the beginning. If [text] changes
/// externally while typing (or after completion), the animation restarts from
/// zero characters — a reply widget should therefore be keyed per message or
/// only receive its final text once.
///
/// Styling falls back to the ambient [DefaultTextStyle]; pass [style] to match
/// the surrounding bubble text exactly.
class ReplyTypewriter extends StatefulWidget {
  /// Creates a typewriter reveal for [text].
  const new({
    required this.text,
    this.charInterval = const Duration(milliseconds: 30),
    this.punctuationPauseFactor = 3.0,
    this.onProgress,
    this.onCompleted,
    this.style,
    super.key,
  });

  /// Full reply text to reveal, one character at a time.
  final String text;

  /// Delay between two consecutive non-punctuation characters.
  final Duration charInterval;

  /// Multiplier applied to [charInterval] after a punctuation character.
  final double punctuationPauseFactor;

  /// Called after every reveal with the currently visible substring.
  final ValueChanged<String>? onProgress;

  /// Called once when the whole [text] is visible.
  final VoidCallback? onCompleted;

  /// Text style override; defaults to the ambient [DefaultTextStyle].
  final TextStyle? style;

  @override
  State<ReplyTypewriter> createState() => _ReplyTypewriterState();
}

class _ReplyTypewriterState extends State<ReplyTypewriter> {
  Timer? _timer;
  int _visibleCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.text.isEmpty) {
      _notifyCompletedAfterFrame();
    } else {
      _scheduleTick(widget.charInterval);
    }
  }

  @override
  void didUpdateWidget(ReplyTypewriter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      // External text changes always restart the reveal from zero.
      _timer?.cancel();
      _timer = null;
      _visibleCount = 0;
      if (widget.text.isEmpty) {
        setState(() {});
        _notifyCompletedAfterFrame();
      } else {
        _scheduleTick(widget.charInterval);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _notifyCompletedAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCompleted?.call();
    });
  }

  void _scheduleTick(Duration delay) {
    _timer = Timer(delay, _tick);
  }

  void _tick() {
    final text = widget.text;
    if (_visibleCount >= text.length) {
      _timer = null;
      return;
    }
    setState(() {
      _visibleCount += 1;
    });
    widget.onProgress?.call(text.substring(0, _visibleCount));
    if (_visibleCount >= text.length) {
      _timer = null;
      widget.onCompleted?.call();
      return;
    }
    final revealed = text.substring(_visibleCount - 1, _visibleCount);
    final isPunctuation = _punctuationChars.contains(revealed);
    _scheduleTick(
      isPunctuation
          ? widget.charInterval * widget.punctuationPauseFactor
          : widget.charInterval,
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final visible = _visibleCount >= text.length
        ? text
        : text.substring(0, _visibleCount);
    return Text(visible, style: widget.style);
  }
}
