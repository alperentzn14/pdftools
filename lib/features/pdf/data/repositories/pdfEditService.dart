import 'dart:io';
import 'dart:ui' show Offset, Size;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfEditService {
  /// Birden fazla PDF'i tek dosyada birleştirir.
  Future<String> merge(List<String> pdfPaths) async {
    if (pdfPaths.isEmpty) throw Exception('Birleştirilecek PDF yok.');

    final outputDoc = PdfDocument();
    outputDoc.pageSettings.margins.all = 0;

    for (final path in pdfPaths) {
      final bytes = await File(path).readAsBytes();
      final sourceDoc = PdfDocument(inputBytes: bytes);

      for (int i = 0; i < sourceDoc.pages.count; i++) {
        final sourcePage = sourceDoc.pages[i];
        final template = sourcePage.createTemplate();

        outputDoc.pageSettings.size =
            Size(sourcePage.size.width, sourcePage.size.height);
        final newPage = outputDoc.pages.add();
        newPage.graphics.drawPdfTemplate(
          template,
          Offset.zero,
          Size(sourcePage.size.width, sourcePage.size.height),
        );
      }
      sourceDoc.dispose();
    }

    final dir = await getApplicationDocumentsDirectory();
    final outPath =
        '${dir.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final savedBytes = await outputDoc.save();
    outputDoc.dispose();
    await File(outPath).writeAsBytes(savedBytes);
    return outPath;
  }

  /// PDF'i belirtilen sayfa numaralarından sonra böler.
  /// [splitAfterPages] 1-indexli sayfa numaraları (örn: [3] → 1-3 | 4-son)
  Future<List<String>> split(
    String pdfPath,
    List<int> splitAfterPages,
  ) async {
    final bytes = await File(pdfPath).readAsBytes();
    final sourceDoc = PdfDocument(inputBytes: bytes);
    final totalPages = sourceDoc.pages.count;
    final dir = await getApplicationDocumentsDirectory();
    final outputPaths = <String>[];

    // Bölme noktalarından sayfa aralıklarını hesapla
    final sortedSplits = [...splitAfterPages]..sort();
    final ranges = <List<int>>[];
    int start = 1;
    for (final splitAt in sortedSplits) {
      if (splitAt >= start && splitAt < totalPages) {
        ranges.add([start, splitAt]);
        start = splitAt + 1;
      }
    }
    ranges.add([start, totalPages]);

    for (int r = 0; r < ranges.length; r++) {
      final range = ranges[r];
      final partDoc = PdfDocument();
      partDoc.pageSettings.margins.all = 0;

      for (int i = range[0] - 1; i < range[1]; i++) {
        final sourcePage = sourceDoc.pages[i];
        final template = sourcePage.createTemplate();
        partDoc.pageSettings.size =
            Size(sourcePage.size.width, sourcePage.size.height);
        final newPage = partDoc.pages.add();
        newPage.graphics.drawPdfTemplate(
          template,
          Offset.zero,
          Size(sourcePage.size.width, sourcePage.size.height),
        );
      }

      final ts = DateTime.now().millisecondsSinceEpoch;
      final outPath = '${dir.path}/split_${r + 1}_$ts.pdf';
      final savedBytes = await partDoc.save();
      partDoc.dispose();
      await File(outPath).writeAsBytes(savedBytes);
      outputPaths.add(outPath);
    }

    sourceDoc.dispose();
    return outputPaths;
  }

  /// Belirtilen sayfaları PDF'den siler.
  /// [pageIndices] 0-indexli sayfa numaraları
  Future<String> deletePages(String pdfPath, List<int> pageIndices) async {
    final bytes = await File(pdfPath).readAsBytes();
    final sourceDoc = PdfDocument(inputBytes: bytes);
    final toDelete = pageIndices.toSet();

    final outputDoc = PdfDocument();
    outputDoc.pageSettings.margins.all = 0;

    for (int i = 0; i < sourceDoc.pages.count; i++) {
      if (toDelete.contains(i)) continue;
      final sourcePage = sourceDoc.pages[i];
      final template = sourcePage.createTemplate();
      outputDoc.pageSettings.size =
          Size(sourcePage.size.width, sourcePage.size.height);
      final newPage = outputDoc.pages.add();
      newPage.graphics.drawPdfTemplate(
        template,
        Offset.zero,
        Size(sourcePage.size.width, sourcePage.size.height),
      );
    }

    sourceDoc.dispose();

    final dir = await getApplicationDocumentsDirectory();
    final outPath =
        '${dir.path}/edited_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final savedBytes = await outputDoc.save();
    outputDoc.dispose();
    await File(outPath).writeAsBytes(savedBytes);
    return outPath;
  }
}
