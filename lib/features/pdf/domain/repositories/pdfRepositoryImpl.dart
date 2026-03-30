import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:PDFly/features/pdf/data/repositories/advancedExcelService.dart';
import 'package:PDFly/features/pdf/data/repositories/pdfCompressService.dart';
import 'package:PDFly/features/pdf/data/repositories/excelPdfService.dart';
import 'package:PDFly/features/pdf/data/repositories/excelService.dart';
import 'package:PDFly/features/pdf/data/repositories/imagePdfService.dart';
import 'package:PDFly/features/pdf/data/repositories/ocrService.dart';
import 'package:PDFly/features/pdf/data/repositories/pdfEditService.dart';
import 'package:PDFly/features/pdf/data/repositories/pdfImageService.dart';
import 'package:PDFly/features/pdf/data/repositories/pdfReaderService.dart';
import 'package:PDFly/features/pdf/data/repositories/pdfService.dart';
import 'package:PDFly/features/pdf/data/repositories/pdfSignatureService.dart';
import 'package:PDFly/features/pdf/data/repositories/wordReaderService.dart';
import 'package:PDFly/features/pdf/data/repositories/wordService.dart';
import 'package:PDFly/features/pdf/domain/repositories/pdfRepository.dart';
import 'package:share_plus/share_plus.dart';

class PdfRepositoryImpl implements PdfRepository {
  final OcrService ocrService;
  final PdfService pdfService;
  final WordService wordService;
  final PdfReaderService pdfReaderService;
  final WordReaderService wordReaderService;
  final ExcelService excelService;
  final ImagePdfService imagePdfService;
  final PdfImageService pdfImageService;
  final ExcelPdfService excelPdfService;
  final PdfEditService pdfEditService;
  final AdvancedExcelService advancedExcelService;
  final PdfSignatureService pdfSignatureService;
  final PdfCompressService pdfCompressService;

  PdfRepositoryImpl(
    this.ocrService,
    this.pdfService,
    this.wordService,
    this.pdfReaderService,
    this.wordReaderService,
    this.excelService,
    this.imagePdfService,
    this.pdfImageService,
    this.excelPdfService,
    this.pdfEditService,
    this.advancedExcelService,
    this.pdfSignatureService,
    this.pdfCompressService,
  );

  /// Daha önce kopyalanmış cache dosyalarını hatırlar.
  /// Aynı oturumda birden fazla işlem yapılırsa cache dosyası silinmiş olabilir.
  final Map<String, String> _stablePathCache = {};

  /// file_picker cache dizinindeki dosyaları kalıcı dizine kopyalar.
  /// Cache dosyaları Android tarafından beklenmedik anda silinebilir.
  Future<String> _ensureStable(String path) async {
    // Daha önce bu yol kopyalandıysa ve kopya hâlâ varsa onu döndür
    final cached = _stablePathCache[path];
    if (cached != null && await File(cached).exists()) {
      return cached;
    }

    final file = File(path);
    if (!await file.exists()) {
      throw Exception('Dosya bulunamadı. Lütfen dosyayı tekrar seçin.');
    }
    // Cache dizinindeyse kalıcı dizine kopyala
    if (path.contains('cache')) {
      final dir = await getApplicationDocumentsDirectory();
      final name = path.split('/').last.split('\\').last;
      final stablePath =
          '${dir.path}/input_${DateTime.now().millisecondsSinceEpoch}_$name';
      await file.copy(stablePath);
      _stablePathCache[path] = stablePath;
      return stablePath;
    }
    return path;
  }

  /// Birden fazla dosya yolunu kararlı hale getirir.
  Future<List<String>> _ensureStableList(List<String> paths) async {
    final result = <String>[];
    for (final p in paths) {
      result.add(await _ensureStable(p));
    }
    return result;
  }

  @override
  Future<String> extractTextFromImage(String path) async {
    final stable = await _ensureStable(path);
    return ocrService.extractText(stable);
  }

  @override
  Future<String> textToPdf(String text) {
    return pdfService.createPdf(text);
  }

  @override
  Future<String> wordToPdf(String docxPath) async {
    final stable = await _ensureStable(docxPath);
    final text = await wordReaderService.extractText(stable);
    return pdfService.createPdf(text);
  }

  @override
  Future<String> pdfToWord(String pdfPath) async {
    final stable = await _ensureStable(pdfPath);
    final text = await pdfReaderService.extractText(stable);
    if (text.trim().isEmpty) {
      throw Exception(
        'Bu PDF\'den metin çıkarılamadı.\n'
        'Taranmış/görüntü tabanlı PDF\'ler için OCR Tarayıcı özelliğini kullanın.',
      );
    }
    return wordService.createWord(text);
  }

  @override
  Future<String> exportToExcel(String pdfPath) async {
    final stable = await _ensureStable(pdfPath);
    final text = await pdfReaderService.extractText(stable);
    if (text.trim().isEmpty) {
      throw Exception(
        'Bu PDF\'den metin çıkarılamadı.\n'
        'Taranmış/görüntü tabanlı PDF\'ler için OCR Tarayıcı özelliğini kullanın.',
      );
    }
    return excelService.createFromText(text);
  }

  @override
  Future<String> imagesToPdf(List<String> imagePaths) async {
    final stable = await _ensureStableList(imagePaths);
    return imagePdfService.createFromImages(stable);
  }

  @override
  Future<List<String>> pdfToImages(String pdfPath, {int dpi = 150}) async {
    final stable = await _ensureStable(pdfPath);
    return pdfImageService.renderPages(stable, dpi: dpi);
  }

  @override
  Future<String> excelToPdf(String xlsxPath) async {
    final stable = await _ensureStable(xlsxPath);
    return excelPdfService.createPdfFromExcel(stable);
  }

  @override
  Future<String> advancedPdfToExcel(String pdfPath) async {
    final stable = await _ensureStable(pdfPath);
    return advancedExcelService.createWithLayout(stable);
  }

  @override
  Future<String> mergePdfs(List<String> pdfPaths) async {
    final stable = await _ensureStableList(pdfPaths);
    return pdfEditService.merge(stable);
  }

  @override
  Future<List<String>> splitPdf(String pdfPath, List<int> splitAfterPages) async {
    final stable = await _ensureStable(pdfPath);
    return pdfEditService.split(stable, splitAfterPages);
  }

  @override
  Future<String> deletePages(String pdfPath, List<int> pageIndices) async {
    final stable = await _ensureStable(pdfPath);
    return pdfEditService.deletePages(stable, pageIndices);
  }

  @override
  Future<String> stampSignature(String pdfPath, Uint8List signatureBytes) async {
    final stable = await _ensureStable(pdfPath);
    return pdfSignatureService.stampSignature(
      pdfPath: stable,
      signatureBytes: signatureBytes,
    );
  }

  @override
  Future<String> convertSingle(String filePath, ConversionType type) async {
    final stable = await _ensureStable(filePath);
    switch (type) {
      case ConversionType.wordToPdf:
        return wordToPdf(stable);
      case ConversionType.pdfToWord:
        return pdfToWord(stable);
      case ConversionType.pdfToExcel:
        return advancedPdfToExcel(stable);
      case ConversionType.imageToPdf:
        return imagesToPdf([stable]);
      case ConversionType.pdfToImages:
        return pdfToImages(stable).then((paths) => paths.first);
    }
  }

  @override
  Future<String> compressPdf(String pdfPath, int level) async {
    final stable = await _ensureStable(pdfPath);
    return pdfCompressService.compress(stable, level: level);
  }

  @override
  Future<void> shareFile(String path) async {
    await Share.shareXFiles([XFile(path)]);
  }
}
