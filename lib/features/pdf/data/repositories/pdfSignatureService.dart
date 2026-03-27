import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Rect;
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfSignatureService {
  /// [signatureBytes] PNG olarak kaydedilmiş imza görüntüsü
  /// İmza son sayfanın sağ-alt köşesine yerleştirilir
  Future<String> stampSignature({
    required String pdfPath,
    required Uint8List signatureBytes,
  }) async {
    final pdfBytes = await File(pdfPath).readAsBytes();
    final document = PdfDocument(inputBytes: pdfBytes);

    final lastPage = document.pages[document.pages.count - 1];
    final image = PdfBitmap(signatureBytes);

    const sigWidth = 160.0;
    const sigHeight = 64.0;
    const margin = 24.0;

    final x = lastPage.size.width - sigWidth - margin;
    final y = lastPage.size.height - sigHeight - margin;

    lastPage.graphics.drawImage(
      image,
      Rect.fromLTWH(x, y, sigWidth, sigHeight),
    );

    final savedBytes = await document.save();
    document.dispose();

    final dir = await getApplicationDocumentsDirectory();
    final outPath =
        '${dir.path}/signed_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await File(outPath).writeAsBytes(savedBytes);
    return outPath;
  }
}
