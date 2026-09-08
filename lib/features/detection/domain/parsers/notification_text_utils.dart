/// Text helpers for Indonesian bank/e-wallet notification parsing.
///
/// Pure functions over notification strings — no IO, no Flutter imports —
/// so they can be unit-tested in isolation.
library;

/// Strips diacritics so "Rp." and "Rp" and "qris" match reliably.
String normalizeText(String input) {
  final lower = input.toLowerCase();
  final buffer = StringBuffer();
  for (final rune in lower.runes) {
    final c = String.fromCharCode(rune);
    buffer.write(c == '–' ? '-' : c);
  }
  return buffer
      .toString()
      .replaceAll(RegExp(r'[^a-z0-9.,:%\s\-]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Extracts the integer rupiah amount from a notification string.
///
/// Returns null when no credible "Rp …" amount is present. Supports:
/// `Rp25.000`, `Rp 1.500.000,00`, `IDR 25.000`, `Rp. 250.000`.
int? extractAmount(String text) {
  final t = normalizeText(text);
  final prefixed = RegExp(r'(?:rp|idr)\s*\.?\s*(\d{1,3}(?:[.,]\d{3})+|\d+)').firstMatch(t);
  final raw = prefixed?.group(1);
  if (raw == null) return null;
  final digits = raw.replaceAll(RegExp(r'[^\d]'), '');
  final value = int.tryParse(digits);
  if (value == null || value <= 0) return null;
  return value;
}

/// True when [text] contains rupiah currency phrasing.
bool containsRupiahAmount(String text) => extractAmount(text) != null;

/// Matches the merchant or counterparty after direction keywords.
///
/// Examples: "di KOPI ABC", "di toko x", "ke BUDI", "kepada BUDI".
String? extractPartyAfter(String text, List<String> markers) {
  final t = normalizeText(text);
  for (final marker in markers) {
    final index = t.indexOf(marker);
    if (index < 0) continue;
    final tail = t.substring(index + marker.length).trim();
    final cleaned = tail
        .replaceFirst(RegExp(r'^(?:dari|ke|kepada|di|atas nama|a\.n\.?|an|pada|untuk)\s+'), '')
        .trim();
    if (cleaned.isEmpty) continue;
    final boundary = RegExp(r'\b(?:sebesar|rp|idr|jam|pukul|wib|wita|wit|tanggal|tgl|ref|no|nomor|berhasil|gagal)\b')
        .firstMatch(cleaned);
    var candidate = boundary == null ? cleaned : cleaned.substring(0, boundary.start);
    candidate = candidate
        .split(RegExp(r'\s{2,}|[,;]\s'))
        .first
        .trim()
        .replaceFirst(RegExp(r'[.]+$'), '');
    if (candidate.isNotEmpty && !candidate.contains(RegExp(r'\d{4,}'))) {
      return candidate.toUpperCase();
    }
  }
  return null;
}

/// Picks the longest candidate from a list of optional captures.
String? longestOf(Iterable<String?> values) {
  String? best;
  for (final v in values) {
    if (v == null) continue;
    if (best == null || v.length > best.length) best = v;
  }
  return best;
}
