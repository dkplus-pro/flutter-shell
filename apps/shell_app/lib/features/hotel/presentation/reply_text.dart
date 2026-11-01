import 'package:fluttershell/features/hotel/data/chat_message.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';

/// Resolves scripted reply keys to localized copy.
///
/// The data layer stores keys only; every [ScriptedReply] must have a
/// matching ARB entry in both languages, enforced by the exhaustive switch.
String resolveReplyText(
  AppLocalizations l10n,
  ScriptedReply reply,
  Map<String, String> params,
) {
  return switch (reply) {
    ScriptedReply.welcome => l10n.chatWelcome(params['room'] ?? ''),
  };
}
