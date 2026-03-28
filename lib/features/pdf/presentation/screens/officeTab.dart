import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfBloc.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfEvent.dart';
import 'package:PDFly/features/pdf/presentation/gradient/appCard.dart';
import 'package:PDFly/features/pdf/presentation/screens/signatureScreen.dart';

class OfficeTab extends StatelessWidget {
  const OfficeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        AppCard(
          child: InkWell(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignatureScreen()),
                ),
            child: _buildItem(Icons.draw, 'İmza +\nDüzenleme'),
          ),
        ),
        AppCard(
          child: InkWell(
            onTap: () async {
              final result = await FilePicker.platform.pickFiles();
              if (result != null && result.files.single.path != null) {
                if (!context.mounted) return;
                context.read<PdfBloc>().add(
                  ShareFileEvent(result.files.single.path!),
                );
              }
            },
            child: _buildItem(Icons.share, 'Hızlı\nPaylaşım'),
          ),
        ),
        AppCard(
          child: InkWell(
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['doc', 'docx'],
              );
              if (result != null && result.files.single.path != null) {
                if (!context.mounted) return;
                context.read<PdfBloc>().add(
                  WordToPdfEvent(result.files.single.path!),
                );
              }
            },
            child: _buildItem(Icons.picture_as_pdf, 'Word → PDF'),
          ),
        ),
        AppCard(
          child: InkWell(
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );
              if (result != null && result.files.single.path != null) {
                if (!context.mounted) return;
                context.read<PdfBloc>().add(
                  PdfToWordEvent(result.files.single.path!),
                );
              }
            },
            child: _buildItem(Icons.description, 'PDF → Word'),
          ),
        ),
        AppCard(
          child: InkWell(
            onTap: () async {
              final image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                if (!context.mounted) return;
                context.read<PdfBloc>().add(OCRToPdfEvent(image.path));
              }
            },
            child: _buildItem(Icons.document_scanner, 'OCR\nTarayıcı'),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(IconData icon, String text) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 10),
        Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }
}
