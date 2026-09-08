import 'package:dompet/features/detection/domain/notification_payload.dart';
import 'package:dompet/features/detection/domain/parsers/indonesian_parsers.dart';
import 'package:dompet/features/detection/domain/transaction_candidate.dart';

/// Parses generic completed bank notifications when no specialized parser matches.
class GenericBankParser extends IndonesianNotificationParser {
  const GenericBankParser();

  @override
  String get parserVersion => 'generic-bank-v1';

  @override
  String? confirmMarker(String text) {
    final t = text.toLowerCase();
    const markers = {'saldo', 'mutasi', 'rekening', 'account', 'nominal', 'sebesar'};
    for (final marker in markers) {
      if (t.contains(marker)) return marker;
    }
    return null;
  }

  @override
  bool allowGeneric(String text) => false;
}

/// Runs specialized parsers in priority order and returns the best result.
class NotificationParserRegistry {
  /// Creates a registry with the default Indonesian parser chain.
  const NotificationParserRegistry({this.parsers = const [QrisParser(), BankTransferParser(), EWalletParser(), GenericBankParser()]});

  /// Ordered parser chain.
  final List<NotificationTransactionParser> parsers;

  /// Parses with every applicable parser and keeps the highest confidence result.
  TransactionCandidate? parse(NotificationPayload payload) {
    final candidates = <TransactionCandidate>[];
    for (final parser in parsers) {
      final candidate = parser.parse(payload);
      if (candidate != null) candidates.add(candidate);
    }
    if (candidates.isEmpty) return null;
    candidates.sort((a, b) => b.confidence.compareTo(a.confidence));
    return candidates.first;
  }
}
