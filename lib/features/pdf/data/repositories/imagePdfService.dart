import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

class ImagePdfService {
  /// JPG/PNG dosyalarını OCR yapmadan direkt PDF sayfalarına gömer.
  Future<String> createFromImages(List<String> imagePaths) async {
    final pdf = pw.Document();

    final notoData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final notoFont = pw.Font.ttf(notoData);

    for (final path in imagePaths) {
      final bytes = await File(path).readAsBytes();
      final image = pw.MemoryImage(bytes);

      pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.zero,
          build: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Image(image, fit: pw.BoxFit.contain),
          ),
        ),
      );
    }

    // Resim yoksa boş sayfa olmasın
    if (imagePaths.isEmpty) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Center(
            child: pw.Text('Boş belge', style: pw.TextStyle(font: notoFont)),
          ),
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      '${dir.path}/images_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }
}
