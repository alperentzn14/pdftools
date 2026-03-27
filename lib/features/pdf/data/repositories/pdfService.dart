import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class PdfService {
  Future<String> createPdf(String text) async {
    final pdf = pw.Document();

    // ✅ Fontları yükle
    final robotoData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
    final notoData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");

    final robotoFont = pw.Font.ttf(robotoData);
    final notoFont = pw.Font.ttf(notoData);

    // ✅ PDF sayfası
    final style = pw.TextStyle(
      font: notoFont,
      fontSize: 14,
      fontFallback: [robotoFont],
    );

    pdf.addPage(
      pw.MultiPage(
        build: (context) => text
            .split('\n')
            .map((line) => pw.Paragraph(
                  text: line.isEmpty ? ' ' : line,
                  style: style,
                ))
            .toList(),
      ),
    );

    // ✅ Dosyayı kaydet
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/file_${DateTime.now().millisecondsSinceEpoch}.pdf",
    );

    await file.writeAsBytes(await pdf.save());

    return file.path;
  }
}
