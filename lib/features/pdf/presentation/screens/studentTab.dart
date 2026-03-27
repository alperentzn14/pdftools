import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfconverter/features/pdf/presentation/bloc/pdfBloc.dart';
import 'package:pdfconverter/features/pdf/presentation/bloc/pdfEvent.dart';
import 'package:pdfconverter/features/pdf/presentation/gradient/appCard.dart';

class StudentTab extends StatelessWidget {
  const StudentTab({super.key});

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
            onTap: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf'],
              );
              if (result != null && result.files.single.path != null) {
                if (!context.mounted) return;
                context
                    .read<PdfBloc>()
                    .add(PdfToWordEvent(result.files.single.path!));
              }
            },
            child: _buildItem(Icons.description, 'PDF → Word'),
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
