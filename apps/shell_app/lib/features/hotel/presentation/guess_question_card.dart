import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';

/// Guess-question categories (docs/06 §3.2): chips filter the FAQ rows.
enum _GuessCategory { delivery, qa, booking }

/// One preset FAQ question; [text] resolves the ARB copy. The question
/// wording is aligned with the scripted intent keywords (docs/06 §3.2:
/// sending a row must hit the intent engine in both locales).
class _GuessQuestion {
  const _GuessQuestion(this.category, this.text);

  final _GuessCategory category;
  final String Function(AppLocalizations l10n) text;
}

final List<_GuessQuestion> _questions = <_GuessQuestion>[
  // Delivery: one question per amenity plus two rotation extras.
  _GuessQuestion(
    _GuessCategory.delivery,
    (l10n) => l10n.faqSlippersDeliver,
  ),
  _GuessQuestion(
    _GuessCategory.delivery,
    (l10n) => l10n.faqToiletriesDeliver,
  ),
  _GuessQuestion(_GuessCategory.delivery, (l10n) => l10n.faqTowelsDeliver),
  _GuessQuestion(_GuessCategory.delivery, (l10n) => l10n.faqWaterDeliver),
  _GuessQuestion(
    _GuessCategory.delivery,
    (l10n) => l10n.faqSlippersExchange,
  ),
  _GuessQuestion(_GuessCategory.delivery, (l10n) => l10n.faqTowelsBath),
  // Q&A: Wi-Fi and breakfast, one extra each.
  _GuessQuestion(_GuessCategory.qa, (l10n) => l10n.faqWifiPassword),
  _GuessQuestion(_GuessCategory.qa, (l10n) => l10n.faqBreakfastTime),
  _GuessQuestion(_GuessCategory.qa, (l10n) => l10n.faqWifiConnect),
  _GuessQuestion(_GuessCategory.qa, (l10n) => l10n.faqBreakfastFloor),
  // Booking: wake-up and late check-out.
  _GuessQuestion(_GuessCategory.booking, (l10n) => l10n.faqWakeupSetup),
  _GuessQuestion(_GuessCategory.booking, (l10n) => l10n.faqWakeupGeneral),
  _GuessQuestion(_GuessCategory.booking, (l10n) => l10n.faqLateCheckoutAsk),
  _GuessQuestion(_GuessCategory.booking, (l10n) => l10n.faqLateCheckoutTime),
];

/// Number of FAQ rows shown per batch (docs/06 §3.2).
const int _batchSize = 4;

/// The "guess you may ask" welcome card (docs/06 §3.2, P2): shown under the
/// welcome bubble while the guest has not sent any message. Category chips
/// filter the FAQ rows; "refresh" rotates the visible batch; tapping a row
/// sends the question as the guest into the normal intent flow. The card is
/// pure presentation state — never persisted.
class GuessQuestionCard extends StatefulWidget {
  const GuessQuestionCard({required this.onSelect, super.key});

  /// Called with the preset question text to send as the guest.
  final ValueChanged<String> onSelect;

  @override
  State<GuessQuestionCard> createState() => _GuessQuestionCardState();
}

class _GuessQuestionCardState extends State<GuessQuestionCard> {
  _GuessCategory _category = _GuessCategory.delivery;
  final Map<_GuessCategory, int> _offsets = <_GuessCategory, int>{};

  List<_GuessQuestion> get _visibleQuestions {
    final pool = _questions
        .where((question) => question.category == _category)
        .toList(growable: false);
    final offset = _offsets[_category] ?? 0;
    return [
      for (var i = 0; i < pool.length && i < _batchSize; i++)
        pool[(offset + i) % pool.length],
    ];
  }

  void _refresh() {
    final poolLength = _questions
        .where((question) => question.category == _category)
        .length;
    setState(() {
      _offsets[_category] = ((_offsets[_category] ?? 0) + 1) % poolLength;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final questions = _visibleQuestions;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: HotelColors.surface,
        borderRadius: BorderRadius.circular(HotelDimens.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.guessCardTitle, style: HotelTypography.titleL),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildChip(l10n, _GuessCategory.delivery, l10n.guessCategoryDelivery),
              _buildChip(l10n, _GuessCategory.qa, l10n.guessCategoryQa),
              _buildChip(
                l10n,
                _GuessCategory.booking,
                l10n.guessCategoryBooking,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          for (var i = 0; i < questions.length; i++) ...[
            if (i > 0) _buildRowDivider(),
            _buildQuestionRow(questions[i]),
          ],
          const SizedBox(height: AppSpacing.xs),
          Center(child: _buildRefreshButton(l10n)),
        ],
      ),
    );
  }

  Widget _buildChip(
    AppLocalizations l10n,
    _GuessCategory category,
    String label,
  ) {
    final selected = category == _category;
    return InkWell(
      onTap: () => setState(() => _category = category),
      borderRadius: BorderRadius.circular(HotelDimens.capsuleRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? HotelColors.primarySoft : HotelColors.tileGray,
          borderRadius: BorderRadius.circular(HotelDimens.capsuleRadius),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? HotelColors.primary : HotelColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionRow(_GuessQuestion question) {
    return InkWell(
      onTap: () => widget.onSelect(question.text(AppLocalizations.of(context))),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                question.text(AppLocalizations.of(context)),
                style: const TextStyle(
                  fontSize: 15,
                  color: HotelColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: HotelColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRowDivider() {
    return Container(height: HotelDimens.hairline, color: HotelColors.divider);
  }

  Widget _buildRefreshButton(AppLocalizations l10n) {
    return InkWell(
      onTap: _refresh,
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.refresh,
              size: 16,
              color: HotelColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(l10n.guessRefresh, style: HotelTypography.sub),
          ],
        ),
      ),
    );
  }
}
