import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

class OcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _warmedUp = false;

  /// App başlangıcında çağır — ML Kit modelini önceden yükler.
  /// İlk OCR çağrısındaki ~3-5 sn model yükleme gecikmesini ortadan kaldırır.
  Future<void> warmUp() async {
    if (_warmedUp) return;
    _warmedUp = true;
    // 1x1 boş resim ile modeli yüklet
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawRect(
      const ui.Rect.fromLTWH(0, 0, 1, 1),
      ui.Paint()..color = const ui.Color(0xFFFFFFFF),
    );
    final picture = recorder.endRecording();
    final img = await picture.toImage(1, 1);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) return;

    final tempDir = await getTemporaryDirectory();
    final warmUpPath = '${tempDir.path}/ocr_warmup.png';
    await File(warmUpPath).writeAsBytes(byteData.buffer.asUint8List());

    try {
      final input = InputImage.fromFilePath(warmUpPath);
      await _textRecognizer.processImage(input);
    } catch (_) {}
    try { await File(warmUpPath).delete(); } catch (_) {}
  }

  Future<String> extractText(String path) async {
    // Native resize — 1080px ML Kit için optimal
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/ocr_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final compressed = await FlutterImageCompress.compressAndGetFile(
      path,
      targetPath,
      minWidth: 1080,
      minHeight: 1080,
      quality: 75,
      format: CompressFormat.jpeg,
    );

    final ocrPath = compressed?.path ?? path;
    final inputImage = InputImage.fromFilePath(ocrPath);
    final recognizedText = await _textRecognizer.processImage(inputImage);

    if (compressed != null) {
      try { await File(ocrPath).delete(); } catch (_) {}
    }

    return recognizedText.text;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
