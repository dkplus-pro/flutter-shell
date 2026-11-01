import 'package:fluttershell/features/hotel/data/chat_message.dart';
import 'package:fluttershell/features/hotel/data/guest_profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hotel_chat_providers.g.dart';

/// Mock guest binding (D8): fixed demo room for the whole session. Not
/// persisted; guest display name is ARB copy resolved at presentation time.
@riverpod
GuestProfile hotelGuestProfile(Ref ref) {
  return const GuestProfile(roomNo: '1208');
}

/// Immutable chat session state: the transcript only; transient UI state
/// (input text, quick panel) stays in the page widget.
class HotelChatState {
  const new({required this.messages});

  final List<ChatMessage> messages;

  HotelChatState withMessage(ChatMessage message) {
    return HotelChatState(messages: [...messages, message]);
  }
}

/// Chat session controller.
///
/// keepAlive: the transcript, the concierge reply queue and the order status
/// timers must survive tab switches and full-page pushes (bridge demo);
/// persistence is written from here so state also survives restarts.
@Riverpod(keepAlive: true)
class HotelChatController extends _$HotelChatController {
  @override
  HotelChatState build() {
    final room = ref.watch(hotelGuestProfileProvider).roomNo;
    return HotelChatState(
      messages: [
        ChatMessage(
          id: 'welcome',
          role: MessageRole.concierge,
          kind: MessageKind.text,
          reply: ScriptedReply.welcome,
          params: <String, String>{'room': room},
          createdAt: DateTime.now(),
        ),
      ],
    );
  }

  /// Appends a guest text message. M2 will route this through the
  /// concierge agent turn queue.
  void sendGuestText(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return;
    }
    state = state.withMessage(
      ChatMessage(
        id: _nextId('m'),
        role: MessageRole.guest,
        kind: MessageKind.text,
        text: text,
        createdAt: DateTime.now(),
      ),
    );
  }

  String _nextId(String prefix) {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return '$prefix${state.messages.length}_$stamp';
  }
}
