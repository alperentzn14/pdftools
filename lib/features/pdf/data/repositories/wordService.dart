import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

class WordService {
  Future<String> createWord(String text) async {
    final dir = await getApplicationDocumentsDirectory();
    final filePath =
        '${dir.path}/file_${DateTime.now().millisecondsSinceEpoch}.docx';
    final bytes = _createDocx(text);
    await File(filePath).writeAsBytes(bytes);
    return filePath;
  }

  Uint8List _createDocx(String text) {
    final paragraphs = text.split('\n').map((line) {
      final safe = line
          .replaceAll('&', '&amp;')
          .replaceAll('<', '&lt;')
          .replaceAll('>', '&gt;');
      return '<w:p><w:r><w:rPr><w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>'
          '<w:sz w:val="24"/></w:rPr>'
          '<w:t xml:space="preserve">$safe</w:t></w:r></w:p>';
    }).join('');

    // [Content_Types].xml — styles.xml de dahil
    const contentTypes =
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
        '<Default Extension="xml" ContentType="application/xml"/>'
        '<Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>'
        '<Override PartName="/word/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.styles+xml"/>'
        '</Types>';

    // _rels/.rels
    const rels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>'
        '</Relationships>';

    // word/_rels/document.xml.rels — styles.xml referansı
    const wordRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
        '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>'
        '</Relationships>';

    // word/styles.xml — varsayılan Normal stili
    const styles = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:styles xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
        '<w:docDefaults>'
        '<w:rPrDefault><w:rPr>'
        '<w:rFonts w:ascii="Calibri" w:hAnsi="Calibri"/>'
        '<w:sz w:val="24"/><w:szCs w:val="24"/>'
        '</w:rPr></w:rPrDefault>'
        '</w:docDefaults>'
        '<w:style w:type="paragraph" w:default="1" w:styleId="Normal">'
        '<w:name w:val="Normal"/>'
        '</w:style>'
        '</w:styles>';

    // word/document.xml
    final document = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
        '<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">'
        '<w:body>'
        '$paragraphs'
        '<w:sectPr>'
        '<w:pgSz w:w="12240" w:h="15840"/>'
        '<w:pgMar w:top="1440" w:right="1440" w:bottom="1440" w:left="1440"/>'
        '</w:sectPr>'
        '</w:body>'
        '</w:document>';

    final archive = Archive();

    void addEntry(String name, String content) {
      final encoded = Uint8List.fromList(utf8.encode(content));
      archive.addFile(ArchiveFile(name, encoded.length, encoded));
    }

    addEntry('[Content_Types].xml', contentTypes);
    addEntry('_rels/.rels', rels);
    addEntry('word/_rels/document.xml.rels', wordRels);
    addEntry('word/styles.xml', styles);
    addEntry('word/document.xml', document);

    final zipped = ZipEncoder().encode(archive);
    if (zipped == null) throw Exception('DOCX oluşturulamadı');
    return Uint8List.fromList(zipped);
  }
}
