import 'dart:io';
import 'dart:ui';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class PdfService {
  Uint8List? _fontBytes;

  Future<void> _ensureFont() async {
    if (_fontBytes != null) return;
    final fontData = await rootBundle.load("assets/fonts/NotoSans-Regular.ttf");
    _fontBytes = fontData.buffer.asUint8List();
  }

  Future<String> createPdf(String text) async {
    await _ensureFont();

    final font = PdfTrueTypeFont(_fontBytes!, 14);
    final doc = PdfDocument();
    final page = doc.pages.add();
    final size = page.getClientSize();
    final bounds = Rect.fromLTWH(40, 40, size.width - 80, size.height - 80);

    // PdfLayoutFormat.paginate otomatik sayfa taşması yönetir
    final format = PdfLayoutFormat(layoutType: PdfLayoutType.paginate);
    final element = PdfTextElement(text: text, font: font);
    element.draw(page: page, bounds: bounds, format: format);

    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/file_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final bytes = await doc.save();
    await File(path).writeAsBytes(bytes);
    doc.dispose();

    return path;
  }
}
