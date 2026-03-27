import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExcelPdfService {
  /// .xlsx dosyasını okuyor ve tablo düzeninde PDF oluşturuyor.
  Future<String> createPdfFromExcel(String xlsxPath) async {
    final bytes = File(xlsxPath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);

    final sheetName = excel.tables.keys.first;
    final sheet = excel.tables[sheetName]!;

    final notoData = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
    final notoFont = pw.Font.ttf(notoData);

    final cellStyle = pw.TextStyle(font: notoFont, fontSize: 9);
    final headerStyle = pw.TextStyle(
      font: notoFont,
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
    );

    // Satırları oluştur
    final rows = <pw.TableRow>[];
    bool isFirst = true;
    for (final row in sheet.rows) {
      final cells = row.map((cell) {
        final value = cell?.value?.toString() ?? '';
        return pw.Container(
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
          ),
          child: pw.Text(
            value,
            style: isFirst ? headerStyle : cellStyle,
            softWrap: true,
          ),
        );
      }).toList();

      rows.add(pw.TableRow(children: cells));
      isFirst = false;
    }

    // Sütun sayısına göre sayfa yönü
    final colCount = sheet.rows.isNotEmpty ? sheet.rows.first.length : 1;
    final pageFormat =
        colCount > 6 ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(16),
        build: (context) => [
          if (rows.isNotEmpty)
            pw.Table(
              columnWidths: {
                for (int i = 0; i < colCount; i++)
                  i: const pw.FlexColumnWidth(1),
              },
              children: rows,
            ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/excel_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await File(path).writeAsBytes(await pdf.save());
    return path;
  }
}
