import 'dart:async';

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttershell/features/hotel/application/hotel_chat_providers.dart';
import 'package:fluttershell/features/hotel/data/chat_message.dart';
import 'package:fluttershell/features/hotel/data/hotel_order.dart';
import 'package:fluttershell/features/hotel/presentation/chat_bubble.dart';
import 'package:fluttershell/features/hotel/presentation/chat_chips.dart';
import 'package:fluttershell/features/hotel/presentation/chat_time_format.dart';
import 'package:fluttershell/features/hotel/presentation/concierge_copy.dart';
import 'package:fluttershell/features/hotel/presentation/order_card.dart';
import 'package:fluttershell/features/hotel/presentation/order_sheet.dart';
import 'package:fluttershell/features/hotel/presentation/quick_services_panel.dart';
import 'package:fluttershell/features/hotel/presentation/reply_text.dart';
import 'package:fluttershell/features/hotel/presentation/typing_indicator.dart';
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

  /// Opens the read-only order sheet (D11). Rows refresh live while the
  /// sheet stays open through the [showHotelOrderSheet] items builder.
  void _showOrderSheet() {
    final l10n = AppLocalizations.of(context);
    final room = ref.read(hotelGuestProfileProvider).roomNo;
    unawaited(
      showHotelOrderSheet(
        context,
        items: _sheetItems(
          l10n,
          ref.read(hotelChatControllerProvider).value,
          room,
        ),
        title: l10n.ordersSheetTitle,
        emptyText: l10n.ordersEmpty,
        liveItems: (ref) => _sheetItems(
          l10n,
          ref.watch(hotelChatControllerProvider).value,
          room,
        ),
      ),
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
    final chat = ref.watch(hotelChatControllerProvider);
    ref.listen(hotelChatControllerProvider, (_, _) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: HotelColors.chatBackground,
      appBar: _buildAppBar(l10n, room),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildBody(l10n, chat)),
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

  /// AsyncValue handling for the restored session: loading spinner, error
  /// view with retry, then the transcript.
  Widget _buildBody(AppLocalizations l10n, AsyncValue<HotelChatState> chat) {
    return chat.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.errorTitle),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => ref.invalidate(hotelChatControllerProvider),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
      data: (state) => ChatMessageList(
        messages: state.messages,
        orders: state.orders,
        roomNo: ref.watch(hotelGuestProfileProvider).roomNo,
        controller: _scroll,
        typing: state.typing,
        freshReplyIds: state.freshReplyIds,
        onConfirm: (orderId, quantity) => ref
            .read(hotelChatControllerProvider.notifier)
            .confirmOrder(orderId, quantity: quantity),
        onRate: (orderId, stars) => ref
            .read(hotelChatControllerProvider.notifier)
            .rateOrder(orderId, stars),
        onChipSelect: _sendText,
        onReplyPlayed: (messageId) => ref
            .read(hotelChatControllerProvider.notifier)
            .markReplyPlayed(messageId),
      ),
    );
  }

  /// Maps session orders to read-only sheet rows (D11), newest first.
  List<HotelOrderSheetItem> _sheetItems(
    AppLocalizations l10n,
    HotelChatState? state,
    String room,
  ) {
    if (state == null) {
      return const <HotelOrderSheetItem>[];
    }
    final orders = state.orders.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return [
      for (final order in orders)
        HotelOrderSheetItem(
          id: order.id,
          title: _sheetTitle(l10n, order),
          subtitle: order.kind == OrderKind.amenity
              ? l10n.orderDeliverTo(room)
              : orderTitle(l10n, order),
          statusLabel: orderStatusLabel(l10n, order),
          status: _sheetStatus(order.status),
          timeText: ChatTimeFormat.hm(order.createdAt),
          icon: orderIcon(order),
        ),
    ];
  }

  String _sheetTitle(AppLocalizations l10n, HotelOrder order) {
    if (order.kind != OrderKind.amenity) {
      return orderSlotSummary(l10n, order, _roomOf(order));
    }
    final amenity = order.amenity;
    if (amenity == null) {
      return orderTitle(l10n, order);
    }
    return '${amenityName(l10n, amenity)} ×${order.quantity}';
  }

  // The room number is the demo-constant guest binding (D8).
  String _roomOf(HotelOrder order) => '1208';

  HotelOrderSheetStatus _sheetStatus(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => HotelOrderSheetStatus.pending,
      OrderStatus.placed => HotelOrderSheetStatus.placed,
      OrderStatus.delivering => HotelOrderSheetStatus.delivering,
      OrderStatus.delivered => HotelOrderSheetStatus.delivered,
      OrderStatus.reserved => HotelOrderSheetStatus.reserved,
      OrderStatus.rated => HotelOrderSheetStatus.rated,
    };
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
          onPressed: _showOrderSheet,
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

/// Transcript list with the day separator, inline timestamps (D12) and the
/// typing indicator while a reply is in flight (PRD 6.2). Fresh concierge
/// replies render through the typewriter reveal (D5); restored history and
/// finished reveals render as plain text.
class ChatMessageList extends StatelessWidget {
  const new({
    required this.messages,
    required this.orders,
    required this.roomNo,
    required this.controller,
    required this.typing,
    required this.freshReplyIds,
    required this.onConfirm,
    required this.onRate,
    required this.onChipSelect,
    required this.onReplyPlayed,
    super.key,
  });

  final List<ChatMessage> messages;
  final Map<String, HotelOrder> orders;
  final String roomNo;
  final ScrollController controller;
  final bool typing;

  /// Reply ids that arrived live this session and still play their reveal.
  final Set<String> freshReplyIds;
  final void Function(String orderId, int quantity) onConfirm;
  final void Function(String orderId, int stars) onRate;
  final ValueChanged<String> onChipSelect;
  final ValueChanged<String> onReplyPlayed;

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
        entries.add(ChatTimestamp(label: ChatTimeFormat.hm(message.createdAt)));
      }
      entries.add(_buildEntry(context, l10n, message));
      previous = message;
    }
    if (typing) {
      entries.add(const TypingIndicator());
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
    switch (message.kind) {
      case MessageKind.order:
        final order = orders[message.orderId];
        if (order == null) {
          return const SizedBox.shrink();
        }
        return OrderCard(
          order: order,
          roomNo: roomNo,
          onConfirm: onConfirm,
          onRate: onRate,
        );
      case MessageKind.chips:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatAvatar(semanticLabel: l10n.conciergeAvatarSemantic),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConciergeText(
                    l10n,
                    message,
                    key: ValueKey('chips-${message.id}'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ChatChips(options: message.chips, onSelect: onChipSelect),
                ],
              ),
            ),
          ],
        );
      case MessageKind.text:
        final text = switch (message.role) {
          MessageRole.guest => message.text ?? '',
          MessageRole.concierge => _resolveConciergeText(l10n, message),
        };
        if (message.role == MessageRole.concierge) {
          return _buildConciergeText(
            l10n,
            message,
            key: ValueKey('text-${message.id}'),
          );
        }
        return ChatBubble(
          role: message.role,
          text: text,
          avatarSemanticLabel: l10n.conciergeAvatarSemantic,
        );
    }
  }

  /// Concierge text bubble: typewriter reveal while the reply is fresh
  /// (keyed per message so a finished reveal never replays), plain text
  /// once played or when restored from persistence.
  Widget _buildConciergeText(
    AppLocalizations l10n,
    ChatMessage message, {
    required Key key,
  }) {
    final text = _resolveConciergeText(l10n, message);
    final isFresh = freshReplyIds.contains(message.id);
    return ChatBubble(
      key: key,
      role: MessageRole.concierge,
      text: text,
      avatarSemanticLabel: l10n.conciergeAvatarSemantic,
      content: isFresh
          ? ReplyTypewriter(
              text: text,
              style: const TextStyle(
                color: HotelColors.textPrimary,
                height: 1.4,
                fontSize: 15,
              ),
              onCompleted: () => onReplyPlayed(message.id),
            )
          : null,
    );
  }

  String _resolveConciergeText(AppLocalizations l10n, ChatMessage message) {
    final reply = message.reply;
    if (reply == null) {
      return '';
    }
    return resolveReplyText(l10n, reply, message.params);
  }
}
