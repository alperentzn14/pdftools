import 'package:flutter/material.dart';
import 'package:pdfconverter/features/pdf/presentation/gradient/appCard.dart';

class PdfListWidget extends StatelessWidget {
  final List<String> files;

  const PdfListWidget({required this.files});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (_, i) {
        return AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(files[i], style: TextStyle(color: Colors.white)),
              Icon(Icons.drag_handle, color: Colors.white),
            ],
          ),
        );
      },
    );
  }
}
