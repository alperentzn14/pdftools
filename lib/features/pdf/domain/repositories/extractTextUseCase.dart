import 'package:PDFly/features/pdf/domain/repositories/pdfRepository.dart';

class ExtractTextUseCase {
  final PdfRepository repository;

  ExtractTextUseCase(this.repository);

  Future<String> call(String path) {
    return repository.extractTextFromImage(path);
  }
}
