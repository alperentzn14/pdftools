import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdfconverter/features/pdf/data/repositories/advancedExcelService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/pdfCompressService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/excelPdfService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/excelService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/imagePdfService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/ocrService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/pdfEditService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/pdfImageService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/pdfReaderService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/pdfService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/pdfSignatureService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/wordReaderService.dart';
import 'package:pdfconverter/features/pdf/data/repositories/wordService.dart';
import 'package:pdfconverter/features/pdf/domain/repositories/pdfRepositoryImpl.dart';
import '../../../../core/utils/file_utils.dart';
import '../bloc/pdfBloc.dart';
import '../bloc/pdfEvent.dart';
import '../bloc/pdfState.dart';

class OCRScreen extends StatelessWidget {
  const OCRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => PdfBloc(
            PdfRepositoryImpl(
              OcrService(),
              PdfService(),
              WordService(),
              PdfReaderService(),
              WordReaderService(),
              ExcelService(),
              ImagePdfService(),
              PdfImageService(),
              ExcelPdfService(),
              PdfEditService(),
              AdvancedExcelService(),
              PdfSignatureService(),
              PdfCompressService(),
            ),
          ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "OCR Tarayıcı",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1E3A8A),
          elevation: 0,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF7C3AED)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: BlocBuilder<PdfBloc, PdfState>(
            builder: (context, state) {
              if (state is PdfLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              if (state is PdfSuccess) {
                return _buildResultView(context, state.filePath);
              }

              if (state is PdfError) {
                return Center(
                  child: Text(
                    "Hata: ${state.message}",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }

              return _buildInitialView(context);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.document_scanner, size: 100, color: Colors.white54),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _pickImage(context),
            icon: const Icon(Icons.photo_library),
            label: const Text("Galeriden Resim Seç"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _actionButton(
                "PDF",
                Icons.picture_as_pdf,
                () => FileUtils.saveAsPdf(text),
              ),
              _actionButton(
                "WORD",
                Icons.description,
                () => FileUtils.saveAsWord(text),
              ),
              _actionButton("YENİ", Icons.refresh, () => _pickImage(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(String label, IconData icon, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3A8A),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      context.read<PdfBloc>().add(ShareFileEvent(image.path));
    }
  }
}
