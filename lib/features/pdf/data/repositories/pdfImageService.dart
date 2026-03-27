import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

class PdfImageService {
  /// PDF'in her sayfasını PNG dosyasına render eder.
  /// [dpi] hedef çözünürlük (varsayılan 150). 72 DPI = 1x, 150 DPI ≈ 2x
  Future<List<String>> renderPages(String pdfPath, {int dpi = 150}) async {
    final document = await PdfDocument.openFile(pdfPath);
    final outputPaths = <String>[];
    final scale = dpi / 72.0;

    final dir = await getApplicationDocumentsDirectory();
    final folderName = 'pdf_images_${DateTime.now().millisecondsSinceEpoch}';
    final folder = Directory('${dir.path}/$folderName');
    await folder.create(recursive: true);

    try {
      for (int i = 1; i <= document.pagesCount; i++) {
        final page = await document.getPage(i);
        try {
          final pageImage = await page.render(
            width: page.width * scale,
            height: page.height * scale,
            format: PdfPageImageFormat.png,
            backgroundColor: '#ffffff',
          );
          if (pageImage == null) continue;

          final pageNumber = i.toString().padLeft(3, '0');
          final filePath = '${folder.path}/page_$pageNumber.png';
          await File(filePath).writeAsBytes(pageImage.bytes);
          outputPaths.add(filePath);
        } finally {
          await page.close();
        }
      }
    } finally {
      await document.close();
    }

    if (outputPaths.isEmpty) {
      throw Exception('PDF\'den resim oluşturulamadı.');
    }

    return outputPaths;
  }
}
