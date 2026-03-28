import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfCompressService {
  /// PDF'i sıkıştırır ve küçültülmüş dosyanın yolunu döner.
  ///
  /// [level]: 0 = hafif (hızlı), 1 = orta, 2 = maksimum (yavaş ama en küçük)
  Future<String> compress(String pdfPath, {int level = 1}) async {
    final bytes = await File(pdfPath).readAsBytes();
    final document = PdfDocument(inputBytes: bytes);

    document.compressionLevel = switch (level) {
      0 => PdfCompressionLevel.bestSpeed,
      2 => PdfCompressionLevel.best,
      _ => PdfCompressionLevel.normal,
    };

    final List<int> savedBytes = await document.save();
    document.dispose();

    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().millisecondsSinceEpoch;
    final outPath = '${dir.path}/compressed_$ts.pdf';
    await File(outPath).writeAsBytes(savedBytes);

    return outPath;
  }
}
