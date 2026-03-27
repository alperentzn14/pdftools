import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdfconverter/features/pdf/data/repositories/pdfSignatureService.dart';
import 'package:signature/signature.dart';

class SignaturePdfScreen extends StatefulWidget {
  final String? initialPdfPath;
  const SignaturePdfScreen({super.key, this.initialPdfPath});

  @override
  State<SignaturePdfScreen> createState() => _SignaturePdfScreenState();
}

class _SignaturePdfScreenState extends State<SignaturePdfScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  late String? _pdfPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _pdfPath = widget.initialPdfPath;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _pdfPath = result.files.single.path);
    }
  }

  Future<void> _saveSignedPdf() async {
    if (_pdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce bir PDF seçin')),
      );
      return;
    }
    if (_controller.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce imzanızı çizin')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final signatureBytes = await _controller.toPngBytes();
      if (signatureBytes == null) throw Exception('İmza alınamadı');

      final outPath = await PdfSignatureService().stampSignature(
        pdfPath: _pdfPath!,
        signatureBytes: signatureBytes,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('İmzalı PDF kaydedildi')),
      );
      await OpenFilex.open(outPath);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fileName = _pdfPath != null
        ? _pdfPath!.split('/').last
        : 'PDF seçilmedi';

    return Scaffold(
      appBar: AppBar(
        title: const Text('İmza + PDF Düzenleme'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'İmzayı Temizle',
            onPressed: () => _controller.clear(),
          ),
        ],
      ),
      body: Column(
        children: [
          // PDF seçim alanı
          InkWell(
            onTap: _pickPdf,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withValues(alpha: 0.08),
                border: Border.all(color: const Color(0xFF1E3A8A)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.picture_as_pdf, color: Color(0xFF1E3A8A)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      fileName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const Icon(Icons.folder_open, color: Colors.grey),
                ],
              ),
            ),
          ),

          // İmza alanı başlığı
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'İmzanızı aşağıya çizin:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // İmza pedi
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Signature(
                  controller: _controller,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Açıklama
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'İmza, PDF\'in son sayfasının sağ-alt köşesine eklenir.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),

          // Butonlar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _controller.clear(),
                    child: const Text('Temizle'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveSignedPdf,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('PDF\'e Ekle'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
