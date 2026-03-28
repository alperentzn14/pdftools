import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:pdfconverter/core/utils/image_preprocess.dart';

class OcrService {
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractText(String path) async {
    final processedFile = await ImagePreprocess.process(path);
    final inputImage = InputImage.fromFilePath(processedFile.path);
    final recognizedText = await textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  void dispose() {
    textRecognizer.close();
  }
}
