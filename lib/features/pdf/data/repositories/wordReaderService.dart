import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';

class WordReaderService {
  Future<String> extractText(String docxPath) async {
    final bytes = await File(docxPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    final docEntry = archive.files.firstWhere(
      (f) => f.name == 'word/document.xml',
      orElse: () => throw Exception('Geçerli bir DOCX dosyası değil'),
    );

    final xml = utf8.decode(docEntry.content as List<int>);

    // <w:t> etiketleri arasındaki metni çıkar
    final buffer = StringBuffer();
    final regex = RegExp(r'<w:t[^>]*>(.*?)</w:t>', dotAll: true);
    for (final match in regex.allMatches(xml)) {
      final part = match.group(1) ?? '';
      if (part.isNotEmpty) {
        buffer.write('$part ');
      }
    }

    // Paragraf sonlarını satır sonu olarak ekle
    final pBreak = RegExp(r'<w:p[ />]');
    final withNewlines = xml.replaceAllMapped(pBreak, (_) => '\n');
    // Tekrar parse et, bu sefer satır sonlarıyla
    final buffer2 = StringBuffer();
    for (final line in withNewlines.split('\n')) {
      final lineMatches = regex.allMatches(line);
      final lineText = lineMatches.map((m) => m.group(1) ?? '').join(' ').trim();
      if (lineText.isNotEmpty) buffer2.writeln(lineText);
    }

    return buffer2.toString().trim();
  }
}
