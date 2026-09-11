import 'dart:io';

import 'package:dompet/features/transactions/domain/receipt_scan_result.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

/// Abstraction over receipt scanning so the presentation layer stays free of
/// platform plugins and can be unit-tested with a fake implementation.
abstract interface class ReceiptScannerService {
  /// Picks an image from the camera or gallery and extracts structured fields.
  Future<ReceiptScanResult?> scanFromGallery();

  /// Picks an image from the camera and extracts structured fields.
  Future<ReceiptScanResult?> scanFromCamera();
}

/// Result of an image-picking attempt. `null` means the user cancelled.
typedef _PickedImage = XFile?;

/// On-device receipt scanner backed by ML Kit text recognition.
///
/// Runs entirely offline: images never leave the device. Raw OCR text is
/// parsed locally into an editable [ReceiptScanResult].
class MlKitReceiptScannerService implements ReceiptScannerService {
  /// Creates the service with an optional [ImagePicker] for testability.
  MlKitReceiptScannerService({ImagePicker? imagePicker}) : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  @override
  Future<ReceiptScanResult?> scanFromGallery() =>
      _scan(_imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 92));

  @override
  Future<ReceiptScanResult?> scanFromCamera() =>
      _scan(_imagePicker.pickImage(source: ImageSource.camera, imageQuality: 92));

  Future<ReceiptScanResult?> _scan(Future<_PickedImage> pending) async {
    final file = await pending;
    if (file == null) return null;

    final recognizer = TextRecognizer();
    try {
      final input = InputImage.fromFilePath(file.path);
      final recognised = await recognizer.processImage(input);
      return ReceiptTextParser.parse(recognised.text);
    } finally {
      await recognizer.close();
      // Best-effort cleanup of the temporary capture.
      try {
        await File(file.path).delete();
      } on FileSystemException {
        // Ignore: cache files are reclaimed by the OS.
      }
    }
  }
}

/// Stateless parser that turns raw OCR text into a [ReceiptScanResult].
///
/// Kept separate from the platform plugin so it can be tested exhaustively.
class ReceiptTextParser {
  ReceiptTextParser._();

  static final _amountLike = RegExp(r'(\d[\d.,]*\d|\d)');
  static final _dateLike = RegExp(r'(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2,4})');
  static const _totalKeywords = ['total', 'jumlah', 'grand total', 'amount', 'nominal', 'bayar', 'tagihan', 'subtotal'];

  /// Parses OCR [text] into a [ReceiptScanResult].
  static ReceiptScanResult parse(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return ReceiptScanResult.empty;

    final lines = trimmed.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    return ReceiptScanResult(
      amount: _extractAmount(lines),
      merchant: _extractMerchant(lines),
      date: _extractDate(trimmed),
      note: _extractNote(lines),
      rawText: trimmed,
    );
  }

  static double? _extractAmount(List<String> lines) {
    // Prefer the value on a line containing a total-ish keyword.
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (_totalKeywords.any(lower.contains)) {
        final amount = _largestAmountIn(line);
        if (amount != null) return amount;
      }
    }
    // Fallback: the largest amount-like token on the receipt.
    final best = <double>[];
    for (final line in lines) {
      final values = _amountsIn(line);
      best.addAll(values);
    }
    if (best.isEmpty) return null;
    best.sort();
    return best.last;
  }

  static double? _largestAmountIn(String line) {
    final values = _amountsIn(line);
    if (values.isEmpty) return null;
    values.sort();
    return values.last;
  }

  static List<double> _amountsIn(String line) {
    final results = <double>[];
    for (final match in _amountLike.allMatches(line)) {
      final parsed = _parseAmount(match.group(0)!);
      if (parsed != null && parsed > 0) results.add(parsed);
    }
    return results;
  }

  /// Parses a localised numeric token. Supports both `1.234,56` and `1,234.56`.
  ///
  /// When a separator is followed by exactly three digits and is the only
  /// separator (e.g. `25.500`, `25,500`), it is treated as a thousands
  /// separator, which is the norm on Indonesian receipts.
  static double? _parseAmount(String token) {
    var cleaned = token.replaceAll(RegExp('[^0-9.,]'), '');
    if (cleaned.isEmpty) return null;

    final lastComma = cleaned.lastIndexOf(',');
    final lastDot = cleaned.lastIndexOf('.');
    final onlySeparatorIndex = lastComma < 0 ? lastDot : (lastDot < 0 ? lastComma : -2);
    final isThousandGroup =
        onlySeparatorIndex >= 0 && cleaned.length > 4 && _digitCountAfter(cleaned, onlySeparatorIndex) == 3;

    if (isThousandGroup) {
      cleaned = cleaned.replaceAll(RegExp('[.,]'), '');
    } else if (lastComma > lastDot) {
      // Comma is the decimal separator: strip dots (grouping), comma -> dot.
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else if (lastDot > lastComma) {
      // Dot is the decimal separator: strip commas (grouping).
      cleaned = cleaned.replaceAll(',', '');
    } else {
      cleaned = cleaned.replaceAll(RegExp('[.,]'), '');
    }

    return double.tryParse(cleaned);
  }

  static int _digitCountAfter(String value, int separatorIndex) {
    if (separatorIndex < 0) return 0;
    return value.length - separatorIndex - 1;
  }

  static String? _extractMerchant(List<String> lines) {
    for (final line in lines) {
      final letters = line.replaceAll(RegExp('[^A-Za-z]'), '');
      // Skip lines that are mostly numbers/dates and very short noise.
      if (letters.length < 3) continue;
      if (_dateLike.hasMatch(line) && letters.length < 5) continue;
      return line.length > 48 ? line.substring(0, 48) : line;
    }
    return null;
  }

  static DateTime? _extractDate(String text) {
    final match = _dateLike.firstMatch(text);
    if (match == null) return null;
    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    var year = int.tryParse(match.group(3)!);
    if (day == null || month == null || year == null) return null;
    if (year < 100) year += 2000;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    try {
      return DateTime(year, month, day);
    } on Object {
      return null;
    }
  }

  static String? _extractNote(List<String> lines) {
    if (lines.isEmpty) return null;
    final header = lines.take(2).join(' — ').trim();
    if (header.isEmpty) return null;
    return header.length > 80 ? header.substring(0, 80) : header;
  }
}
