import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfBloc.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfEvent.dart';
import 'package:PDFly/features/pdf/presentation/gradient/appCard.dart';

class AccountingTab extends StatelessWidget {
  const AccountingTab({super.key});

  void _comingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Yakında'),
            content: Text('$feature özelliği yakında eklenecek.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tamam'),
              ),
            ],
          ),
    );
  }

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
                context.read<PdfBloc>().add(
                  ExportToExcelEvent(result.files.single.path!),
                );
              }
            },
            child: _buildItem(Icons.table_chart, "Excel'e\nAktar"),
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
            onTap: () => _comingSoon(context, 'Klasörleme'),
            child: _buildItem(Icons.folder_open, 'Klasörleme'),
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
