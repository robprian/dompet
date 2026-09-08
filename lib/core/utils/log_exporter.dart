// We use SharePlus inside the function but the package structure causes this lint
// ignore_for_file: deprecated_member_use
import 'dart:io';

import 'package:dompet/core/logger/dompet_logger.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Utility class to package and export runtime Talker logs via system share sheet.
class LogExporter {
  /// Writes current Talker log history to a text file and launches the share sheet.
  static Future<void> exportLogs() async {
    final directory = await getApplicationSupportDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/dompet-$timestamp.txt');

    final logs = talker.history.map((e) => e.generateTextMessage()).join('\n');
    await file.writeAsString(logs);

    await Share.shareXFiles([XFile(file.path)], text: 'Dompet CE Debug Logs');
  }
}
