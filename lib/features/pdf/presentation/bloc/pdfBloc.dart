import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_filex/open_filex.dart';
import 'package:PDFly/features/pdf/domain/repositories/pdfRepository.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfEvent.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfState.dart';

class PdfBloc extends Bloc<PdfEvent, PdfState> {
  final PdfRepository repo;

  PdfBloc(this.repo) : super(PdfInitial()) {
    on<OCRToPdfEvent>(_ocrToPdf);
    on<TextToPdfEvent>(_textToPdf);
    on<WordToPdfEvent>(_wordToPdf);
    on<PdfToWordEvent>(_pdfToWord);
    on<ExportToExcelEvent>(_exportToExcel);
    on<ShareFileEvent>(_share);
    on<OpenFileEvent>(_open);
    on<ImagesToPdfEvent>(_imagesToPdf);
    on<PdfToImagesEvent>(_pdfToImages);
    on<ExcelToPdfEvent>(_excelToPdf);
    on<MergePdfsEvent>(_mergePdfs);
    on<SplitPdfEvent>(_splitPdf);
    on<DeletePagesEvent>(_deletePages);
    on<AddPdfSignatureEvent>(_addSignature);
    on<BatchConvertEvent>(_batchConvert);
    on<AdvancedPdfToExcelEvent>(_advancedPdfToExcel);
    on<OCRBatchEvent>(_ocrBatch);
    on<CompressPdfEvent>(_compressPdf);
  }

  Future<void> _ocrToPdf(OCRToPdfEvent event, Emitter emit) async {
    emit(PdfLoading());
    try {
      final text = await repo.extractTextFromImage(event.imagePath);
      final pdfPath = await repo.textToPdf(text);
      emit(PdfSuccess(filePath: pdfPath));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> _textToPdf(TextToPdfEvent event, Emitter emit) async {
    emit(PdfLoading());
    try {
      final path = await repo.textToPdf(event.text);
      emit(PdfSuccess(filePath: path));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> _wordToPdf(WordToPdfEvent event, Emitter emit) async {
    emit(PdfLoading());
    try {
      final path = await repo.wordToPdf(event.path);
      emit(PdfSuccess(filePath: path));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> _pdfToWord(PdfToWordEvent event, Emitter emit) async {
    emit(PdfLoading());
    try {
      final path = await repo.pdfToWord(event.path);
      emit(PdfSuccess(filePath: path));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> _exportToExcel(ExportToExcelEvent event, Emitter emit) async {
    emit(PdfLoading());
    try {
      final path = await repo.exportToExcel(event.pdfPath);
      emit(PdfSuccess(filePath: path));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> _share(ShareFileEvent event, Emitter emit) async {
    await repo.shareFile(event.path);
  }

  Future<void> _open(OpenFileEvent event, Emitter emit) async {
    try {
      final result = await OpenFilex.open(event.path);
      if (result.type != ResultType.done) {
        // Dosya paylaşım ile açılmayı dene
        await repo.shareFile(event.path);
      }
    } catch (_) {
      await repo.shareFile(event.path);
    }
  }

  Future<void> _imagesToPdf(ImagesToPdfEvent event, Emitter emit) async {
    emit(PdfLoading());
    try {
      final path = await repo.imagesToPdf(event.imagePaths);
      emit(PdfSuccess(filePath: path));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> _pdfToImages(PdfToImagesEvent event, Emitter emit) async {
    emit(PdfLoading());
    try {
      final paths = await repo.pdfToImages(event.pdfPath, dpi: event.dpi);
      emit(PdfMultiImageSuccess(paths));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> _excelToPdf(ExcelToPdfEvent event, Emitter emit) async {
    emit(PdfLoading());
    try {
      final path = await repo.excelToPdf(event.xlsxPath);
      emit(PdfSuccess(filePath: path));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> _mergePdfs(MergePdfsEvent event, Emitter emit) async {
    emit(PdfLoading());
    try {
      final path = await repo.mergePdfs(event.pdfPaths);
      emit(PdfSuccess(filePath: path));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> _splitPdf(SplitPdfEvent event, Emitter emit) async {
    emit(PdfLoading());
    try {
      final paths = await repo.splitPdf(event.pdfPath, event.splitAfterPages);
      emit(PdfBatchSuccess(paths));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> _deletePages(DeletePagesEvent event, Emitter emit) async {
    emit(PdfLoading());
    try {
      final path = await repo.deletePages(event.pdfPath, event.pageIndices);
      emit(PdfSuccess(filePath: path));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> _addSignature(AddPdfSignatureEvent event, Emitter emit) async {
    emit(PdfLoading());
    try {
      final path = await repo.stampSignature(
        event.pdfPath,
        event.signatureBytes,
      );
      emit(PdfSuccess(filePath: path));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> _advancedPdfToExcel(
    AdvancedPdfToExcelEvent event,
    Emitter emit,
  ) async {
    emit(PdfLoading());
    try {
      final path = await repo.advancedPdfToExcel(event.pdfPath);
      emit(PdfSuccess(filePath: path));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> _batchConvert(BatchConvertEvent event, Emitter emit) async {
    final total = event.filePaths.length;
    emit(PdfBatchProgress(completed: 0, total: total, currentFileName: ''));

    final results = <String>[];
    for (int i = 0; i < event.filePaths.length; i++) {
      final path = event.filePaths[i];
      emit(
        PdfBatchProgress(
          completed: i,
          total: total,
          currentFileName: path.split('/').last.split('\\').last,
        ),
      );
      try {
        final outPath = await repo.convertSingle(path, event.type);
        results.add(outPath);
      } catch (_) {
        // Hatalı dosyayı atla, devam et
      }
    }
    emit(PdfBatchSuccess(results));
  }

  Future<void> _ocrBatch(OCRBatchEvent event, Emitter emit) async {
    final total = event.imagePaths.length;
    emit(PdfBatchProgress(completed: 0, total: total, currentFileName: ''));
    try {
      final buffer = StringBuffer();
      for (int i = 0; i < event.imagePaths.length; i++) {
        final imagePath = event.imagePaths[i];
        final fileName = imagePath.split('/').last.split('\\').last;
        emit(
          PdfBatchProgress(
            completed: i,
            total: total,
            currentFileName: fileName,
          ),
        );
        if (i > 0) buffer.writeln('\n');
        final text = await repo.extractTextFromImage(imagePath);
        buffer.writeln(text.trim());
      }
      final pdfPath = await repo.textToPdf(buffer.toString());
      emit(PdfSuccess(filePath: pdfPath));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }

  Future<void> _compressPdf(CompressPdfEvent event, Emitter emit) async {
    emit(PdfLoading());
    try {
      final path = await repo.compressPdf(event.pdfPath, event.level);
      emit(PdfSuccess(filePath: path));
    } catch (e) {
      emit(PdfError(e.toString()));
    }
  }
}
