import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImagePreprocess {
  /// OCR öncesi görüntüyü hazırlar.
  ///
  /// ML Kit 4000px altı görüntüleri kendi içinde iyi işler.
  /// Sadece çok büyük görüntülerde (>4000px) küçültme yapar.
  /// Küçük/orta görüntüleri olduğu gibi bırakarak gereksiz
  /// decode/encode süresinden kaçınır.
  static Future<File> process(String path) async {
    final file = File(path);
    final bytes = await file.readAsBytes();

    // Boyutu hızlıca kontrol et (tam decode etmeden)
    final info = img.findDecoderForData(bytes);
    if (info == null) return file;

    // Sadece dosya 3MB+ ise ön işleme yap (büyük kamera fotoğrafları)
    // Küçük dosyalarda decode/encode süresi kazançtan fazla olur
    if (bytes.length < 3 * 1024 * 1024) return file;

    final processedBytes = await compute(_processImage, bytes);
    if (processedBytes == null) return file;

    final tempDir = await getTemporaryDirectory();
    final newPath =
        '${tempDir.path}/proc_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final processedFile = File(newPath);
    await processedFile.writeAsBytes(processedBytes);
    return processedFile;
  }

  static Uint8List? _processImage(Uint8List bytes) {
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return null;

    // Sadece çok büyük görüntüleri küçült
    const maxWidth = 2400;
    if (image.width <= maxWidth && image.height <= maxWidth) return null;

    final scale = maxWidth / (image.width > image.height ? image.width : image.height);
    image = img.copyResize(
      image,
      width: (image.width * scale).round(),
      height: (image.height * scale).round(),
      interpolation: img.Interpolation.average,
    );

    return Uint8List.fromList(img.encodeJpg(image, quality: 85));
  }
}
