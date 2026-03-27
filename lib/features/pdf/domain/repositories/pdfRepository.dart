import 'dart:typed_data';

enum ConversionType { wordToPdf, pdfToWord, pdfToExcel, imageToPdf, pdfToImages }

abstract class PdfRepository {
  Future<String> extractTextFromImage(String path);
  Future<void> shareFile(String path);

  Future<String> textToPdf(String text);
  Future<String> wordToPdf(String docxPath);
  Future<String> pdfToWord(String pdfPath);
  Future<String> exportToExcel(String pdfPath);

  // Yeni dönüşüm metodları
  Future<String> imagesToPdf(List<String> imagePaths);
  Future<List<String>> pdfToImages(String pdfPath, {int dpi});
  Future<String> excelToPdf(String xlsxPath);
  Future<String> advancedPdfToExcel(String pdfPath);

  // PDF düzenleme
  Future<String> mergePdfs(List<String> pdfPaths);
  Future<List<String>> splitPdf(String pdfPath, List<int> splitAfterPages);
  Future<String> deletePages(String pdfPath, List<int> pageIndices);
  Future<String> stampSignature(String pdfPath, Uint8List signatureBytes);

  // Toplu işlem için tek dosya dönüştürme
  Future<String> convertSingle(String filePath, ConversionType type);
}
