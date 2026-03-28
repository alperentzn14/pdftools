import 'dart:typed_data';
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

  @override
  Future<String> extractTextFromImage(String path) {
    return ocrService.extractText(path);
  }

  @override
  Future<String> textToPdf(String text) {
    return pdfService.createPdf(text);
  }

  @override
  Future<String> wordToPdf(String docxPath) async {
    final text = await wordReaderService.extractText(docxPath);
    return pdfService.createPdf(text);
  }

  @override
  Future<String> pdfToWord(String pdfPath) async {
    final text = await pdfReaderService.extractText(pdfPath);
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
    final text = await pdfReaderService.extractText(pdfPath);
    if (text.trim().isEmpty) {
      throw Exception(
        'Bu PDF\'den metin çıkarılamadı.\n'
        'Taranmış/görüntü tabanlı PDF\'ler için OCR Tarayıcı özelliğini kullanın.',
      );
    }
    return excelService.createFromText(text);
  }

  @override
  Future<String> imagesToPdf(List<String> imagePaths) {
    return imagePdfService.createFromImages(imagePaths);
  }

  @override
  Future<List<String>> pdfToImages(String pdfPath, {int dpi = 150}) {
    return pdfImageService.renderPages(pdfPath, dpi: dpi);
  }

  @override
  Future<String> excelToPdf(String xlsxPath) {
    return excelPdfService.createPdfFromExcel(xlsxPath);
  }

  @override
  Future<String> advancedPdfToExcel(String pdfPath) {
    return advancedExcelService.createWithLayout(pdfPath);
  }

  @override
  Future<String> mergePdfs(List<String> pdfPaths) {
    return pdfEditService.merge(pdfPaths);
  }

  @override
  Future<List<String>> splitPdf(String pdfPath, List<int> splitAfterPages) {
    return pdfEditService.split(pdfPath, splitAfterPages);
  }

  @override
  Future<String> deletePages(String pdfPath, List<int> pageIndices) {
    return pdfEditService.deletePages(pdfPath, pageIndices);
  }

  @override
  Future<String> stampSignature(String pdfPath, Uint8List signatureBytes) {
    return pdfSignatureService.stampSignature(
      pdfPath: pdfPath,
      signatureBytes: signatureBytes,
    );
  }

  @override
  Future<String> convertSingle(String filePath, ConversionType type) {
    switch (type) {
      case ConversionType.wordToPdf:
        return wordToPdf(filePath);
      case ConversionType.pdfToWord:
        return pdfToWord(filePath);
      case ConversionType.pdfToExcel:
        return advancedPdfToExcel(filePath);
      case ConversionType.imageToPdf:
        return imagesToPdf([filePath]);
      case ConversionType.pdfToImages:
        return pdfToImages(filePath).then((paths) => paths.first);
    }
  }

  @override
  Future<String> compressPdf(String pdfPath, int level) {
    return pdfCompressService.compress(pdfPath, level: level);
  }

  @override
  Future<void> shareFile(String path) async {
    await Share.shareXFiles([XFile(path)]);
  }
}
