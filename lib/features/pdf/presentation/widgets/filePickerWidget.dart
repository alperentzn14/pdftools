import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdfconverter/features/pdf/presentation/gradient/appCard.dart';

class FilePickerWidget extends StatelessWidget {
  final Function(String path) onPicked;

  const FilePickerWidget({required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: ListTile(
        leading: Icon(Icons.upload_file, color: Colors.white),
        title: Text("Dosya Seç", style: TextStyle(color: Colors.white)),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () async {
          final result = await FilePicker.platform.pickFiles();

          if (result != null) {
            onPicked(result.files.single.path!);
          }
        },
      ),
    );
  }
}
