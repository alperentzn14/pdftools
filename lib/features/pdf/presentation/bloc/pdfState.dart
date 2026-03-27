import 'package:equatable/equatable.dart';

abstract class PdfState extends Equatable {
  const PdfState();

  @override
  List<Object?> get props => [];
}

class PdfInitial extends PdfState {}

class PdfLoading extends PdfState {}

class PdfSuccess extends PdfState {
  final String filePath;
  final String? extractedText;

  const PdfSuccess({required this.filePath, this.extractedText});

  @override
  List<Object?> get props => [filePath, extractedText];
}

class PdfError extends PdfState {
  final String message;

  const PdfError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Toplu işlem sırasında ilerleme durumu
class PdfBatchProgress extends PdfState {
  final int completed;
  final int total;
  final String currentFileName;

  const PdfBatchProgress({
    required this.completed,
    required this.total,
    required this.currentFileName,
  });

  @override
  List<Object?> get props => [completed, total, currentFileName];
}

/// Toplu işlem tamamlandı
class PdfBatchSuccess extends PdfState {
  final List<String> filePaths;

  const PdfBatchSuccess(this.filePaths);

  @override
  List<Object?> get props => [filePaths];
}

/// PDF → Resim işlemi tamamlandı (birden fazla PNG)
class PdfMultiImageSuccess extends PdfState {
  final List<String> imagePaths;

  const PdfMultiImageSuccess(this.imagePaths);

  @override
  List<Object?> get props => [imagePaths];
}
