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
enum ScriptedReply {
  welcome,
  askQuantity,
  quantityInvalid,
  cancelAck,
  askWakeupTime,
  askLateCheckoutTime,
  timeChipsPrompt,
  wifiAnswer,
  breakfastAnswer,
  fallback,
}

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
    this.chips = const <String>[],
  });

  factory fromJson(Map<String, Object?> json) {
    final replyName = json['reply'] as String?;
    final chips = json['chips'] as List<Object?>?;
    return ChatMessage(
      id: json['id']! as String,
      role: MessageRole.values.byName(json['role']! as String),
      kind: MessageKind.values.byName(json['kind']! as String),
      text: json['text'] as String?,
      reply: replyName == null ? null : ScriptedReply.values.byName(replyName),
      params:
          (json['params'] as Map<Object, Object?>? ??
                  const <Object?, Object?>{})
              .cast<String, String>(),
      orderId: json['orderId'] as String?,
      chips: chips?.cast<String>() ?? const <String>[],
      createdAt: DateTime.parse(json['createdAt']! as String),
    );
  }

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

  /// Tappable options for [MessageKind.chips]; each value is sent back as a
  /// guest message when tapped (time-slot suggestions must stay parseable).
  final List<String> chips;

  final DateTime createdAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'role': role.name,
    'kind': kind.name,
    'text': text,
    'reply': reply?.name,
    'params': params,
    'orderId': orderId,
    'chips': chips,
    'createdAt': createdAt.toIso8601String(),
  };
}
