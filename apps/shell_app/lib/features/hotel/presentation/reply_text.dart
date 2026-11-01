import 'package:fluttershell/features/hotel/data/chat_message.dart';
import 'package:fluttershell/features/hotel/presentation/concierge_copy.dart';
import 'package:fluttershell/l10n/generated/app_localizations.dart';

/// Resolves scripted reply keys to localized copy.
///
/// Kept as the stable rendering entry point for chat replies; the actual
/// resolution lives in `concierge_copy.dart`.
String resolveReplyText(
  AppLocalizations l10n,
  ScriptedReply reply,
  Map<String, String> params,
) {
  return resolveConciergeCopy(l10n, reply, params);
}
