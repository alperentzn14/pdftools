import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PdfSummaryScreen extends StatelessWidget {
  final String text;
  const PdfSummaryScreen({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Özeti'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Kopyala',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Metin kopyalandı')),
              );
            },
          ),
        ],
      ),
      body: text.isEmpty
          ? const Center(child: Text('PDF\'den metin çıkarılamadı.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                text,
                style: const TextStyle(fontSize: 15, height: 1.7),
              ),
            ),
    );
  }
}
