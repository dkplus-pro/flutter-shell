import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttershell/features/hotel/application/hotel_chat_providers.dart';
import 'package:fluttershell/features/hotel/data/chat_message.dart';
import 'package:fluttershell/features/hotel/presentation/chat_bubble.dart';
import 'package:fluttershell/features/hotel/presentation/chat_time_format.dart';
import 'package:fluttershell/features/hotel/presentation/quick_services_panel.dart';
import 'package:fluttershell/features/hotel/presentation/reply_text.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';

/// AI concierge chat page: the "Services" tab (PRD 5, D4).
class HotelChatPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<HotelChatPage> createState() => _HotelChatPageState();
}

class _HotelChatPageState extends ConsumerState<HotelChatPage> {
  final ScrollController _scroll = ScrollController();
  final TextEditingController _input = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  bool _panelOpen = false;

  @override
  void initState() {
    super.initState();
    _inputFocus.addListener(_handleFocusChanged);
  }

  @override
  void dispose() {
    _scroll.dispose();
    _input.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  /// Keyboard and quick panel are mutually exclusive (PRD 6.4): focusing the
  /// input collapses the panel.
  void _handleFocusChanged() {
    if (_inputFocus.hasFocus && _panelOpen) {
      setState(() => _panelOpen = false);
    }
  }

  void _togglePanel() {
    if (_panelOpen) {
      setState(() => _panelOpen = false);
      return;
    }
    _inputFocus.unfocus();
    setState(() => _panelOpen = true);
  }

  void _sendText(String raw) {
    ref.read(hotelChatControllerProvider.notifier).sendGuestText(raw);
  }

  void _sendFromInput() {
    final text = _input.text;
    if (text.trim().isEmpty) {
      return;
    }
    _sendText(text);
    _input.clear();
  }

  void _onQuickSelect(String preset) {
    _sendText(preset);
    setState(() => _panelOpen = false);
  }

  void _showOrdersPlaceholder() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(l10n.placeholderNotAvailable)),
      );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) {
        return;
      }
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final room = ref.watch(hotelGuestProfileProvider).roomNo;
    final messages = ref.watch(
      hotelChatControllerProvider.select((state) => state.messages),
    );
    ref.listen(hotelChatControllerProvider, (_, _) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: HotelColors.chatBackground,
      appBar: _buildAppBar(l10n, room),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ChatMessageList(messages: messages, controller: _scroll),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.bottomCenter,
              child: _panelOpen
                  ? QuickServicesPanel(onSelect: _onQuickSelect)
                  : const SizedBox(width: double.infinity),
            ),
            _buildInputBar(l10n),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n, String room) {
    final badge = l10n.hotelRoomBadge(room, l10n.hotelMockGuestName);
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.hotelChatTitle),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            label: badge,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: HotelColors.gold.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontSize: 12,
                  color: HotelColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.receipt_long_outlined),
          tooltip: l10n.hotelOrdersTooltip,
          onPressed: _showOrdersPlaceholder,
        ),
      ],
    );
  }

  Widget _buildInputBar(AppLocalizations l10n) {
    return Container(
      color: HotelColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                _panelOpen ? Icons.close : Icons.add_circle_outline,
                color: HotelColors.primary,
              ),
              tooltip: l10n.quickPanelSemantic,
              onPressed: _togglePanel,
            ),
            Expanded(
              child: TextField(
                controller: _input,
                focusNode: _inputFocus,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendFromInput(),
                decoration: InputDecoration(
                  hintText: l10n.chatInputHint,
                  isDense: true,
                  filled: true,
                  fillColor: HotelColors.chatBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _input,
              builder: (context, value, _) {
                final enabled = value.text.trim().isNotEmpty;
                return IconButton(
                  icon: Icon(
                    Icons.send,
                    color: enabled
                        ? HotelColors.primary
                        : HotelColors.textSecondary,
                  ),
                  tooltip: l10n.chatSendSemantic,
                  onPressed: enabled ? _sendFromInput : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Transcript list with the day separator and inline timestamps (D12).
class ChatMessageList extends StatelessWidget {
  const new({required this.messages, required this.controller, super.key});

  final List<ChatMessage> messages;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final entries = <Widget>[];
    if (messages.isNotEmpty) {
      entries.add(
        ChatDateSeparator(
          label: l10n.chatTodayMarker(
            ChatTimeFormat.day(messages.first.createdAt),
          ),
        ),
      );
    }
    ChatMessage? previous;
    for (final message in messages) {
      final previousTime = previous?.createdAt ?? message.createdAt;
      final gap = message.createdAt.difference(previousTime);
      if (previous != null &&
          previous.role == message.role &&
          gap > const Duration(minutes: 5)) {
        entries.add(
          ChatTimestamp(label: ChatTimeFormat.hm(message.createdAt)),
        );
      }
      entries.add(_buildEntry(context, l10n, message));
      previous = message;
    }
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: entries[index],
        );
      },
    );
  }

  Widget _buildEntry(
    BuildContext context,
    AppLocalizations l10n,
    ChatMessage message,
  ) {
    final text = switch (message.role) {
      MessageRole.guest => message.text ?? '',
      MessageRole.concierge => _resolveConciergeText(l10n, message),
    };
    return ChatBubble(
      role: message.role,
      text: text,
      avatarSemanticLabel: l10n.conciergeAvatarSemantic,
    );
  }

  String _resolveConciergeText(
    AppLocalizations l10n,
    ChatMessage message,
  ) {
    final reply = message.reply;
    if (reply == null) {
      return '';
    }
    return resolveReplyText(l10n, reply, message.params);
  }
}
