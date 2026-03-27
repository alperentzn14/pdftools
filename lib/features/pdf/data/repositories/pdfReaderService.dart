import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfReaderService {
  Future<String> extractText(String pdfPath) async {
    final bytes = await File(pdfPath).readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final extractor = PdfTextExtractor(document);
    final text = extractor.extractText();
    document.dispose();
    return text;
  }
}
