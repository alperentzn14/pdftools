import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExcelService {
  Future<String> createFromText(String text) async {
    final excel = Excel.createExcel();
    // Varsayılan sayfayı kullan (Sheet1)
    final sheet = excel['Sheet1'];

    final lines = text
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    for (int i = 0; i < lines.length; i++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i))
          .value = TextCellValue(lines[i].trim());
    }

    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/excel_${DateTime.now().millisecondsSinceEpoch}.xlsx';
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Excel encode edilemedi');
    await File(path).writeAsBytes(bytes);
    return path;
  }
}
