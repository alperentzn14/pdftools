import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImagePreprocess {
  /// OCR öncesi görüntüyü hazırlar.
  ///
  /// Tesseract için hedef çözünürlük 2000px — LSTM motoru bu boyutta
  /// hem hızlı hem doğru çalışır. 4000px+ mobilde dakikalarca sürebilir.
  static Future<File> process(String path) async {
    final bytes = await File(path).readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) return File(path);

    // 1. Büyütme — hedef: 2000px genişlik (Tesseract için optimal)
    if (image.width < 2000) {
      final scale = 2000.0 / image.width;
      image = img.copyResize(
        image,
        width: (image.width * scale).round(),
        height: (image.height * scale).round(),
        interpolation: img.Interpolation.cubic,
      );
    } else if (image.width > 2500) {
      // Çok büyük görüntüleri küçült — Tesseract LSTM'i yavaşlatır
      final scale = 2000.0 / image.width;
      image = img.copyResize(
        image,
        width: 2000,
        height: (image.height * scale).round(),
        interpolation: img.Interpolation.average,
      );
    }

    // 2. Gri tonlama
    image = img.grayscale(image);

    // 3. Kontrast artırma
    image = img.adjustColor(image, contrast: 1.8);

    // 4. Keskinleştirme (büyütme sonrası)
    image = img.convolution(image, filter: [0, -1, 0, -1, 5, -1, 0, -1, 0]);

    final tempDir = await getTemporaryDirectory();
    final newPath =
        '${tempDir.path}/proc_${DateTime.now().millisecondsSinceEpoch}.png';

    final processedFile = File(newPath);
    await processedFile.writeAsBytes(img.encodePng(image));

    return processedFile;
  }
}
