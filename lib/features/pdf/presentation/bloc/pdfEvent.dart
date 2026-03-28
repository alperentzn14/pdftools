import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:pdfconverter/features/pdf/domain/repositories/pdfRepository.dart';

export 'package:pdfconverter/features/pdf/domain/repositories/pdfRepository.dart'
    show ConversionType;

abstract class PdfEvent extends Equatable {
  const PdfEvent();

  @override
  List<Object?> get props => [];
}

/// OCR → PDF
class OCRToPdfEvent extends PdfEvent {
  final String imagePath;
  const OCRToPdfEvent(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}

/// Text → PDF
class TextToPdfEvent extends PdfEvent {
  final String text;
  const TextToPdfEvent(this.text);
  @override
  List<Object?> get props => [text];
}

/// Word → PDF
class WordToPdfEvent extends PdfEvent {
  final String path;
  const WordToPdfEvent(this.path);
  @override
  List<Object?> get props => [path];
}

/// PDF → Word
class PdfToWordEvent extends PdfEvent {
  final String path;
  const PdfToWordEvent(this.path);
  @override
  List<Object?> get props => [path];
}

/// Share
class ShareFileEvent extends PdfEvent {
  final String path;
  const ShareFileEvent(this.path);
  @override
  List<Object?> get props => [path];
}

/// Open
class OpenFileEvent extends PdfEvent {
  final String path;
  const OpenFileEvent(this.path);
  @override
  List<Object?> get props => [path];
}

/// PDF → Excel
class ExportToExcelEvent extends PdfEvent {
  final String pdfPath;
  const ExportToExcelEvent(this.pdfPath);
  @override
  List<Object?> get props => [pdfPath];
}

/// Resimler → PDF (OCR değil, direkt gömme)
class ImagesToPdfEvent extends PdfEvent {
  final List<String> imagePaths;
  const ImagesToPdfEvent(this.imagePaths);
  @override
  List<Object?> get props => [imagePaths];
}

/// PDF → PNG (sayfa başına bir resim)
class PdfToImagesEvent extends PdfEvent {
  final String pdfPath;
  final int dpi;
  const PdfToImagesEvent(this.pdfPath, {this.dpi = 150});
  @override
  List<Object?> get props => [pdfPath, dpi];
}

/// Excel → PDF
class ExcelToPdfEvent extends PdfEvent {
  final String xlsxPath;
  const ExcelToPdfEvent(this.xlsxPath);
  @override
  List<Object?> get props => [xlsxPath];
}

/// PDF birleştirme
class MergePdfsEvent extends PdfEvent {
  final List<String> pdfPaths;
  const MergePdfsEvent(this.pdfPaths);
  @override
  List<Object?> get props => [pdfPaths];
}

/// PDF bölme
class SplitPdfEvent extends PdfEvent {
  final String pdfPath;
  final List<int> splitAfterPages;
  const SplitPdfEvent(this.pdfPath, this.splitAfterPages);
  @override
  List<Object?> get props => [pdfPath, splitAfterPages];
}

/// Sayfa silme
class DeletePagesEvent extends PdfEvent {
  final String pdfPath;
  final List<int> pageIndices; // 0-indexli
  const DeletePagesEvent(this.pdfPath, this.pageIndices);
  @override
  List<Object?> get props => [pdfPath, pageIndices];
}

/// PDF'e imza ekle
class AddPdfSignatureEvent extends PdfEvent {
  final String pdfPath;
  final Uint8List signatureBytes;
  const AddPdfSignatureEvent(this.pdfPath, this.signatureBytes);
  @override
  List<Object?> get props => [pdfPath, signatureBytes];
}

/// Toplu dönüştürme
class BatchConvertEvent extends PdfEvent {
  final List<String> filePaths;
  final ConversionType type;
  const BatchConvertEvent(this.filePaths, this.type);
  @override
  List<Object?> get props => [filePaths, type];
}

/// Gelişmiş PDF → Excel (tablo korumalı)
class AdvancedPdfToExcelEvent extends PdfEvent {
  final String pdfPath;
  const AdvancedPdfToExcelEvent(this.pdfPath);
  @override
  List<Object?> get props => [pdfPath];
}

/// Toplu OCR
class OCRBatchEvent extends PdfEvent {
  final List<String> imagePaths;
  const OCRBatchEvent(this.imagePaths);
  @override
  List<Object?> get props => [imagePaths];
}

/// PDF Sıkıştır — level: 0=hafif, 1=orta, 2=maksimum
class CompressPdfEvent extends PdfEvent {
  final String pdfPath;
  final int level;
  const CompressPdfEvent(this.pdfPath, this.level);
  @override
  List<Object?> get props => [pdfPath, level];
}
