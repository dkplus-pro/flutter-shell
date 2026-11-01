/// Role of a chat participant in the hotel concierge session.
enum MessageRole { guest, concierge }

/// Payload kind carried by a [ChatMessage].
///
/// - `text`: plain copy (guest raw input or scripted concierge reply).
/// - `order`: structured order card rendered from a [String] order id.
/// - `chips`: tappable quick options (used for time slot suggestions).
enum MessageKind { text, order, chips }

/// Localization keys for scripted concierge copy.
///
/// The data layer only stores keys plus string params; user-visible copy is
/// resolved at presentation time from ARB so a locale switch re-renders the
/// whole transcript (AGENTS l10n rule).
enum ScriptedReply { welcome }

/// One entry of the concierge transcript.
class ChatMessage {
  const new({
    required this.id,
    required this.role,
    required this.kind,
    required this.createdAt,
    this.text,
    this.reply,
    this.params = const <String, String>{},
    this.orderId,
  });

  /// Unique, stable id; also the persistence key inside the transcript.
  final String id;

  final MessageRole role;
  final MessageKind kind;

  /// Guest raw input; null for scripted concierge replies.
  final String? text;

  /// Scripted reply key; null for guest messages.
  final ScriptedReply? reply;

  /// String params for [reply] interpolation (e.g. room number).
  final Map<String, String> params;

  /// Referenced order for [MessageKind.order].
  final String? orderId;

  final DateTime createdAt;
}
