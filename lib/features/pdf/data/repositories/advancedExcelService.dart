import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class AdvancedExcelService {
  /// PDF'den metin çıkarırken sütun yapısını korumaya çalışır.
  /// Ardışık çoklu boşlukları sütun ayırıcı olarak kullanır.
  Future<String> createWithLayout(String pdfPath) async {
    final bytes = await File(pdfPath).readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final extractor = PdfTextExtractor(document);
    final rawText = extractor.extractText();
    document.dispose();

    if (rawText.trim().isEmpty) {
      throw Exception(
        'Bu PDF\'den metin çıkarılamadı.\n'
        'Taranmış PDF için OCR Tarayıcı özelliğini kullanın.',
      );
    }

    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    final lines = rawText
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    for (int rowIdx = 0; rowIdx < lines.length; rowIdx++) {
      final line = lines[rowIdx];

      // Birden fazla boşluk veya tab karakteri sütun sınırı olarak kabul et
      final columns = line
          .split(RegExp(r'  +|\t'))
          .map((c) => c.trim())
          .where((c) => c.isNotEmpty)
          .toList();

      if (columns.length > 1) {
        // Tablo satırı gibi görünüyor
        for (int colIdx = 0; colIdx < columns.length; colIdx++) {
          sheet
              .cell(CellIndex.indexByColumnRow(
                columnIndex: colIdx,
                rowIndex: rowIdx,
              ))
              .value = TextCellValue(columns[colIdx]);
        }
      } else {
        // Tek sütun
        sheet
            .cell(CellIndex.indexByColumnRow(
              columnIndex: 0,
              rowIndex: rowIdx,
            ))
            .value = TextCellValue(line.trim());
      }
    }

    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/advanced_excel_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final encoded = excel.encode();
    if (encoded == null) throw Exception('Excel encode edilemedi');
    await File(path).writeAsBytes(encoded);
    return path;
  }
}
