import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImagePreprocess {
  static Future<File> process(String path) async {
    final bytes = await File(path).readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) return File(path);

    // 1. Gri Tonlama (OCR için standart)
    image = img.grayscale(image);

    // 2. Kontrast Artırma (Yazıları belirginleştirir)
    image = img.adjustColor(image, contrast: 1.5);

    // 3. Keskinleştirme (Bulanık yazıları düzeltir)
    image = img.convolution(image, filter: [0, -1, 0, -1, 5, -1, 0, -1, 0]);

    // 4. Eşikleme (Thresholding - Arka planı temizler)
    image = img.luminanceThreshold(image, threshold: 0.5);

    final tempDir = await getTemporaryDirectory();
    final newPath =
        "${tempDir.path}/proc_${DateTime.now().millisecondsSinceEpoch}.jpg";

    final processedFile = File(newPath);
    await processedFile.writeAsBytes(img.encodeJpg(image));

    return processedFile;
  }
}
