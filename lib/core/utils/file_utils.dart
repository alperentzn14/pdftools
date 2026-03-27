import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';

class FileUtils {
  static Future<void> saveAsPdf(String text) async {
    final pdf = pw.Document();

    // Türkçe destekli font yükleme
    final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: ttf),
        build:
            (pw.Context context) => pw.Padding(
              padding: const pw.EdgeInsets.all(20),
              child: pw.Text(
                text,
                style: pw.TextStyle(font: ttf, fontSize: 14),
              ),
            ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/ocr_result_${DateTime.now().millisecond}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(file.path)], text: 'PDF Sonucu');
  }

  static Future<void> saveAsWord(String text) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/ocr_result_${DateTime.now().millisecond}.txt',
    );

    // UTF-8 ile tüm dilleri destekler
    await file.writeAsBytes(utf8.encode(text));

    await Share.shareXFiles([XFile(file.path)], text: 'Metin Sonucu');
  }
}
