import 'package:dompet/features/detection/domain/detection_enums.dart';
import 'package:dompet/features/detection/domain/notification_payload.dart';
import 'package:dompet/features/detection/domain/parsers/notification_text_utils.dart';
import 'package:dompet/features/detection/domain/transaction_candidate.dart';

/// Shared Indonesian text-parsing core for the pluggable parsers.
///
/// Subclasses supply recognition keywords and scoring rules; this base class
/// performs amount extraction, direction detection, and party extraction.
abstract class IndonesianNotificationParser implements NotificationTransactionParser {
  const IndonesianNotificationParser();

  /// Stable parser version string reported on every candidate.
  @override
  String get parserVersion;

  /// Keyword hit that confirms this parser family (e.g. "qris", "transfer").
  String? confirmMarker(String text);

  @override
  TransactionCandidate? parse(NotificationPayload payload) {
    final title = payload.title;
    final body = payload.body;
    final text = '$title $body';
    final normalizedSource = '$title $body'.trim();

    if (_indicatesFailure(text)) return null;
    final amount = extractAmount(text);
    if (amount == null) return null;
    final marker = confirmMarker(text);
    if (marker == null && !allowGeneric(text)) return null;

    final direction = _detectDirection(text);
    final method = detectMethod(text);
    final merchant = _extractMerchant(text);
    final counterparty = _extractCounterparty(text);
    final referenceId = _extractReference(text);

    final score = scoreCandidate(
      hasStrongMarker: marker != null,
      hasParty: (merchant ?? counterparty) != null,
      hasReference: referenceId != null,
      direction: direction,
      amount: amount,
      text: text,
    );

    if (score < minConfidence) return null;

    final source = payload.package.trim().toLowerCase();
    return TransactionCandidate(
      fingerprint: TransactionCandidate.makeFingerprint(
        sourcePackage: source,
        amount: amount,
        type: direction,
        merchant: merchant,
        referenceId: referenceId,
        occurredAt: payload.postedAt,
      ),
      amount: amount,
      type: direction,
      method: method,
      confidence: score,
      confidenceTier: _tierFor(score),
      occurredAt: payload.postedAt,
      parserVersion: parserVersion,
      sourcePackage: source,
      merchant: merchant,
      counterparty: counterparty,
      referenceId: referenceId,
      maskedAccount: _extractMaskedAccount(text),
      categoryHint: merchant,
      sourceText: normalizedSource,
    );
  }

  /// Payment channel for the parsed text.
  PaymentMethod detectMethod(String text) => PaymentMethod.other;

  /// When true, this parser may parse texts without its signature keyword.
  bool allowGeneric(String text) => false;

  /// Minimum confidence a candidate must reach to be emitted.
  double get minConfidence => 0.5;

  /// Computes the 0.0-1.0 confidence for a successful parse.
  double scoreCandidate({
    required bool hasStrongMarker,
    required bool hasParty,
    required bool hasReference,
    required DetectionTransactionType direction,
    required int amount,
    required String text,
  }) {
    var score = 0.5;
    if (hasStrongMarker) score += 0.22;
    if (hasParty) score += 0.15;
    if (hasReference) score += 0.05;
    if (_directionWordCount(text) >= 2) score += 0.04;
    if (amount > 100000000) score -= 0.05;
    return _bounded(score);
  }

  DetectionTransactionType _detectDirection(String text) {
    final t = text.toLowerCase();
    final explicitIncome = _countHits(t, explicitIncomeMarkers) > 0;
    final explicitExpense = _countHits(t, explicitExpenseMarkers) > 0;
    if (explicitIncome && !explicitExpense) return DetectionTransactionType.income;
    if (explicitExpense && !explicitIncome) return DetectionTransactionType.expense;
    final incomeHits = _countHits(t, incomeMarkers);
    final expenseHits = _countHits(t, expenseMarkers);
    if (incomeHits > expenseHits) return DetectionTransactionType.income;
    if (expenseHits > incomeHits) return DetectionTransactionType.expense;
    return DetectionTransactionType.expense;
  }

  bool _indicatesFailure(String text) {
    return _countHits(text, failureMarkers) > _countHits(text, successMarkers);
  }

  String? _extractMerchant(String text) {
    return extractPartyAfter(text, const ['di toko', 'di merchant', 'di']);
  }

  String? _extractCounterparty(String text) {
    return extractPartyAfter(text, const [
      'kepada',
      'ke rekening',
      'atas nama',
      'a.n.',
      'a.n',
      'an',
      'dari',
      'penerima',
      'ke',
    ]);
  }

  String? _extractReference(String text) {
    final t = normalizeText(text);
    for (final marker in const ['no referensi', 'referensi', 'ref ', 'no ref', 'nomor referensi', 'ref id']) {
      final index = t.indexOf(marker);
      if (index < 0) continue;
      final tail = t.substring(index + marker.length).trim();
      final match = RegExp(r'^[a-z0-9\-_/]{6,24}').firstMatch(tail);
      if (match != null) return match.group(0);
    }
    return null;
  }

  String? _extractMaskedAccount(String text) {
    final match = RegExp(
      r'(?:\*{2,}|x{2,}|•{2,}|[0-9]{2,})\*+\d{1,4}|(?:no\.?\s?)?(?:rek|akun|kartu)\s*[:.]?\s*[\d\s*]{6,}',
    ).firstMatch(normalizeText(text));
    return match?.group(0);
  }

  static double _bounded(double value) {
    return _round(_clamp(value, 0.98));
  }

  /// Rounds a score to two decimals so confidence tiers stay stable.
  static double _round(double value) => (value * 100).round() / 100;

  static double _clamp(double value, double ceiling) {
    if (value > ceiling) return ceiling;
    if (value < 0) return 0;
    return value;
  }

  static int _countHits(String text, Set<String> markers) {
    var count = 0;
    for (final marker in markers) {
      if (text.toLowerCase().contains(marker)) count++;
    }
    return count;
  }

  static int _directionWordCount(String text) {
    return _countHits(text, incomeMarkers) + _countHits(text, expenseMarkers);
  }

  static ConfidenceTier _tierFor(double score) {
    if (score >= 0.9) return ConfidenceTier.high;
    if (score >= 0.7) return ConfidenceTier.likely;
    if (score >= 0.5) return ConfidenceTier.uncertain;
    return ConfidenceTier.rejected;
  }

  /// Markers indicating money arrived (income).
  static const Set<String> incomeMarkers = {
    'transfer masuk',
    'dana masuk',
    'diterima',
    'penerimaan',
    'masuk ke',
    'saldo bertambah',
    'kredit',
    'pemindahan dana masuk',
    'incoming transfer',
    'deposit',
    'top up',
    'top-up',
    'topup',
    'uang masuk',
  };

  /// Markers indicating money left (expense).
  static const Set<String> expenseMarkers = {
    'transfer keluar',
    'dana keluar',
    'terkirim ke',
    'pembayaran',
    'pembelian',
    'pemakaian',
    'debit',
    'dibayar',
    'belanja',
    'terbayar',
    'outgoing transfer',
    'tarik tunai',
    'penarikan',
    'uang keluar',
    'qris',
  };

  /// Unambiguous markers that money arrived.
  static const Set<String> explicitIncomeMarkers = {
    'transfer masuk',
    'dana masuk',
    'diterima',
    'kredit',
    'uang masuk',
    'masuk ke',
    'pemindahan dana masuk',
    'incoming transfer',
    'penerimaan',
  };

  /// Unambiguous markers that money left.
  static const Set<String> explicitExpenseMarkers = {
    'transfer keluar',
    'dana keluar',
    'terkirim',
    'debit',
    'uang keluar',
    'penarikan',
    'outgoing transfer',
    'tarik tunai',
  };

  /// Markers suggesting the attempt did not complete.
  static const Set<String> failureMarkers = {
    'gagal',
    'ditolak',
    'tidak berhasil',
    'batal',
    'failed',
    'declined',
    'insufficient',
    'gagal diproses',
    'saldo tidak cukup',
  };

  /// Markers that positively indicate completion.
  static const Set<String> successMarkers = {
    'berhasil',
    'sukses',
    'success',
    'terkonfirmasi',
    'selesai',
    'transaksi berhasil',
  };
}

/// Parses Indonesian QRIS payment notifications.
class QrisParser extends IndonesianNotificationParser {
  const QrisParser();

  @override
  String get parserVersion => 'qris-v1';

  @override
  String? confirmMarker(String text) {
    final t = text.toLowerCase();
    if (t.contains('qris')) return 'qris';
    return null;
  }

  @override
  PaymentMethod detectMethod(String text) => PaymentMethod.qris;

  @override
  double scoreCandidate({
    required bool hasStrongMarker,
    required bool hasParty,
    required bool hasReference,
    required DetectionTransactionType direction,
    required int amount,
    required String text,
  }) {
    final base = super.scoreCandidate(
      hasStrongMarker: hasStrongMarker,
      hasParty: hasParty,
      hasReference: hasReference,
      direction: direction,
      amount: amount,
      text: text,
    );
    if (!hasStrongMarker) return base;
    if (direction != DetectionTransactionType.expense) return _boundedScore(base - 0.2);
    var adjusted = 0.6 + (hasParty ? 0.3 : 0.12);
    if (hasReference) adjusted += 0.05;
    return _boundedScore(adjusted);
  }

  static double _boundedScore(double value) {
    return IndonesianNotificationParser._round(IndonesianNotificationParser._clamp(value, 0.97));
  }
}

/// Parses Indonesian bank transfer notifications (incoming/outgoing).
class BankTransferParser extends IndonesianNotificationParser {
  const BankTransferParser();

  @override
  String get parserVersion => 'bank-transfer-v1';

  @override
  String? confirmMarker(String text) {
    final t = text.toLowerCase();
    const markers = {
      'transfer masuk',
      'transfer keluar',
      'transfer',
      'dana masuk',
      'dana keluar',
      'pemindahan dana',
      'dana diterima',
      'dana terkirim',
      'incoming transfer',
      'outgoing transfer',
      'kredit',
      'debit',
      'diterima',
      'masuk',
      'dikirim',
      'salary',
      'payroll',
      'gaji',
    };
    for (final m in markers) {
      if (t.contains(m)) return m;
    }
    return null;
  }

  @override
  PaymentMethod detectMethod(String text) => PaymentMethod.bank;

  @override
  double scoreCandidate({
    required bool hasStrongMarker,
    required bool hasParty,
    required bool hasReference,
    required DetectionTransactionType direction,
    required int amount,
    required String text,
  }) {
    final t = text.toLowerCase();
    final isIncoming =
        t.contains('masuk') || t.contains('diterima') || t.contains('kredit') || t.contains('dana masuk');
    final isOutgoing = t.contains('keluar') || t.contains('terkirim') || t.contains('debit') || t.contains('dibayar');
    final explicit = isIncoming != isOutgoing;
    final base = super.scoreCandidate(
      hasStrongMarker: hasStrongMarker,
      hasParty: hasParty,
      hasReference: hasReference,
      direction: direction,
      amount: amount,
      text: text,
    );
    if (!hasStrongMarker) return base;
    var adjusted = 0.55 + (explicit ? 0.15 : 0.0) + (hasParty ? 0.2 : 0.1) + (hasReference ? 0.05 : 0.0);
    if (explicit && hasParty) adjusted += 0.05;
    return _boundedScore(adjusted);
  }

  static double _boundedScore(double value) {
    return IndonesianNotificationParser._round(IndonesianNotificationParser._clamp(value, 0.97));
  }
}

/// Parses Indonesian e-wallet notifications (GoPay, OVO, DANA, ShopeePay...).
class EWalletParser extends IndonesianNotificationParser {
  const EWalletParser();

  static const Set<String> walletKeywords = {
    'gopay',
    'ovo',
    'dana',
    'shopeepay',
    'shopee pay',
    'linkaja',
    'isaku',
    'astrapay',
    'gojek',
    'kamu bayar',
    'kamu terima',
    'pembayaran diterima',
    'uang masuk ke',
    'uang keluar dari',
  };

  @override
  String get parserVersion => 'ewallet-v1';

  @override
  String? confirmMarker(String text) {
    final t = text.toLowerCase();
    for (final keyword in walletKeywords) {
      if (t.contains(keyword)) return keyword;
    }
    return null;
  }

  @override
  PaymentMethod detectMethod(String text) => PaymentMethod.ewallet;

  @override
  bool allowGeneric(String text) => text.toLowerCase().contains('saldo');
}
