import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:PDFly/features/pdf/domain/repositories/pdfRepository.dart';

enum _FileCategory { pdf, word, excel, image, mixed }

// --------------- Icon builder helpers ---------------

/// PDF → DOC tarzı dönüşüm ikonu: üst badge (kaynak) → alt badge (hedef)
Widget _convIcon(String from, Color fromC, String to, Color toC) {
  return Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: Colors.white.withAlpha(28),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _badge(from, fromC),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 1),
          child: Icon(Icons.arrow_downward, color: Colors.white70, size: 8),
        ),
        _badge(to, toC),
      ],
    ),
  );
}

/// Tek format ikonu (ör. OCR → PDF)
Widget _singleIcon(String label, Color color, {IconData? icon}) {
  return Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(height: 2),
        ],
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: icon != null ? 9 : 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    ),
  );
}

/// Düzenleme ikonu (birleştir, böl, sil vb.)
Widget _editIcon(IconData icon, Color color) {
  return Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, color: Colors.white, size: 24),
  );
}

Widget _badge(String text, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  decoration: BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(3),
  ),
  child: Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 8,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.2,
    ),
  ),
);

// Renk sabitleri
const _kPdf = Color(0xFFD32F2F); // kırmızı
const _kDoc = Color(0xFF1565C0); // mavi
const _kXls = Color(0xFF2E7D32); // yeşil
const _kJpg = Color(0xFFE65100); // turuncu
const _kPng = Color(0xFF6A1B9A); // mor
const _kOcr = Color(0xFF00695C); // teal
const _kEdit = Color(0xFF1E3A8A); // koyu mavi

// --------------- Model ---------------

class _OpItem {
  final Widget iconWidget;
  final String titleKey;
  final String subtitleKey;
  final String estSec;
  final VoidCallback onTap;

  const _OpItem({
    required this.iconWidget,
    required this.titleKey,
    required this.subtitleKey,
    required this.estSec,
    required this.onTap,
  });
}

// --------------- Widget ---------------

class OperationList extends StatelessWidget {
  final List<PlatformFile> files;
  final bool isImages;
  final void Function(dynamic event) onDispatch;

  const OperationList({
    super.key,
    required this.files,
    required this.isImages,
    required this.onDispatch,
  });

  _FileCategory _detectCategory() {
    if (isImages) return _FileCategory.image;
    if (files.isEmpty) return _FileCategory.mixed;

    final extensions =
        files.map((f) => (f.extension ?? '').toLowerCase()).toSet();
    if (extensions.length > 1) return _FileCategory.mixed;
    final ext = extensions.first;
    if (ext == 'pdf') return _FileCategory.pdf;
    if (ext == 'doc' || ext == 'docx') return _FileCategory.word;
    if (ext == 'xls' || ext == 'xlsx') return _FileCategory.excel;
    return _FileCategory.mixed;
  }

  List<_OpItem> _buildOps() {
    final cat = _detectCategory();
    final paths =
        files.map((f) => f.path ?? '').where((p) => p.isNotEmpty).toList();
    final isMulti = files.length > 1;

    switch (cat) {
      case _FileCategory.pdf:
        if (isMulti) {
          return [
            _OpItem(
              iconWidget: _singleIcon('PDF', _kEdit, icon: Icons.merge_type),
              titleKey: 'ops.merge_pdf',
              subtitleKey: 'ops.merge_pdf_sub',
              estSec: '3',
              onTap: () => onDispatch(OpMergePdfsRequest(paths)),
            ),
            _OpItem(
              iconWidget: _convIcon('PDF', _kPdf, 'DOC', _kDoc),
              titleKey: 'ops.batch_convert',
              subtitleKey: 'ops.batch_convert_sub',
              estSec: '5',
              onTap:
                  () => onDispatch(
                    OpBatchRequest(paths, ConversionType.pdfToWord),
                  ),
            ),
          ];
        }
        final path = paths.first;
        return [
          _OpItem(
            iconWidget: _convIcon('PDF', _kPdf, 'DOC', _kDoc),
            titleKey: 'ops.pdf_to_word',
            subtitleKey: 'ops.pdf_to_word_sub',
            estSec: '2',
            onTap: () => onDispatch(OpPdfToWordRequest(path)),
          ),
          _OpItem(
            iconWidget: _convIcon('PDF', _kPdf, 'XLS', _kXls),
            titleKey: 'ops.pdf_to_excel',
            subtitleKey: 'ops.pdf_to_excel_sub',
            estSec: '3',
            onTap: () => onDispatch(OpAdvancedExcelRequest(path)),
          ),
          _OpItem(
            iconWidget: _convIcon('PDF', _kPdf, 'PNG', _kPng),
            titleKey: 'ops.pdf_to_image',
            subtitleKey: 'ops.pdf_to_image_sub',
            estSec: '4',
            onTap: () => onDispatch(OpPdfToImagesRequest(path)),
          ),
          _OpItem(
            iconWidget: _singleIcon('PDF', _kEdit, icon: Icons.merge_type),
            titleKey: 'ops.merge_pdf',
            subtitleKey: 'ops.merge_pdf_sub',
            estSec: '3',
            onTap: () => onDispatch(OpOpenMergeScreenRequest()),
          ),
          _OpItem(
            iconWidget: _editIcon(Icons.call_split, const Color(0xFF283593)),
            titleKey: 'ops.split_pdf',
            subtitleKey: 'ops.split_pdf_sub',
            estSec: '2',
            onTap: () => onDispatch(OpOpenSplitScreenRequest(path)),
          ),
          _OpItem(
            iconWidget: _editIcon(
              Icons.delete_outline,
              const Color(0xFFB71C1C),
            ),
            titleKey: 'ops.delete_pages',
            subtitleKey: 'ops.delete_pages_sub',
            estSec: '2',
            onTap: () => onDispatch(OpOpenDeletePagesRequest(path)),
          ),
          _OpItem(
            iconWidget: _singleIcon(
              'PDF',
              const Color(0xFF1A237E),
              icon: Icons.draw,
            ),
            titleKey: 'ops.sign_pdf',
            subtitleKey: 'ops.sign_pdf_sub',
            estSec: '2',
            onTap: () => onDispatch(OpSignPdfRequest(path)),
          ),
          _OpItem(
            iconWidget: _editIcon(Icons.compress, const Color(0xFF00796B)),
            titleKey: 'ops.compress_pdf',
            subtitleKey: 'ops.compress_pdf_sub',
            estSec: '3',
            onTap: () => onDispatch(OpCompressPdfRequest(path)),
          ),
          _OpItem(
            iconWidget: _editIcon(Icons.share, const Color(0xFF546E7A)),
            titleKey: 'ops.share_file',
            subtitleKey: 'ops.share_file_sub',
            estSec: '1',
            onTap: () => onDispatch(OpShareRequest(path)),
          ),
        ];

      case _FileCategory.word:
        if (isMulti) {
          return [
            _OpItem(
              iconWidget: _convIcon('DOC', _kDoc, 'PDF', _kPdf),
              titleKey: 'ops.batch_convert',
              subtitleKey: 'ops.batch_convert_sub',
              estSec: '5',
              onTap:
                  () => onDispatch(
                    OpBatchRequest(paths, ConversionType.wordToPdf),
                  ),
            ),
          ];
        }
        return [
          _OpItem(
            iconWidget: _convIcon('DOC', _kDoc, 'PDF', _kPdf),
            titleKey: 'ops.word_to_pdf',
            subtitleKey: 'ops.word_to_pdf_sub',
            estSec: '2',
            onTap: () => onDispatch(OpWordToPdfRequest(paths.first)),
          ),
        ];

      case _FileCategory.excel:
        return [
          _OpItem(
            iconWidget: _convIcon('XLS', _kXls, 'PDF', _kPdf),
            titleKey: 'ops.excel_to_pdf',
            subtitleKey: 'ops.excel_to_pdf_sub',
            estSec: '2',
            onTap: () => onDispatch(OpExcelToPdfRequest(paths.first)),
          ),
        ];

      case _FileCategory.image:
        final imgPaths = files.map((f) => f.path ?? '').toList();
        return [
          _OpItem(
            iconWidget: _convIcon('IMG', _kJpg, 'PDF', _kPdf),
            titleKey: 'ops.image_to_pdf',
            subtitleKey: 'ops.image_to_pdf_sub',
            estSec: '2',
            onTap: () => onDispatch(OpImagesToPdfRequest(imgPaths)),
          ),
          _OpItem(
            iconWidget: _singleIcon('OCR', _kOcr, icon: Icons.document_scanner),
            titleKey: 'ops.ocr_to_pdf',
            subtitleKey: 'ops.ocr_to_pdf_sub',
            estSec: '3',
            onTap:
                () =>
                    imgPaths.length == 1
                        ? onDispatch(OpOcrRequest(imgPaths.first))
                        : onDispatch(OpOcrBatchRequest(imgPaths)),
          ),
        ];

      case _FileCategory.mixed:
        return [
          _OpItem(
            iconWidget: _editIcon(Icons.share, const Color(0xFF546E7A)),
            titleKey: 'ops.share_file',
            subtitleKey: 'ops.share_file_sub',
            estSec: '1',
            onTap: () => onDispatch(OpShareRequest(paths.first)),
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final ops = _buildOps();
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: ops.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _OperationTile(op: ops[i]),
    );
  }
}

class _OperationTile extends StatelessWidget {
  final _OpItem op;
  const _OperationTile({required this.op});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withAlpha(25),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: op.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              op.iconWidget,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      op.titleKey.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      op.subtitleKey.tr(),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'est_time'.tr(namedArgs: {'sec': op.estSec}),
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------- Request marker sınıfları (public) ---------------
class OpPdfToWordRequest {
  final String path;
  OpPdfToWordRequest(this.path);
}

class OpAdvancedExcelRequest {
  final String path;
  OpAdvancedExcelRequest(this.path);
}

class OpPdfToImagesRequest {
  final String path;
  OpPdfToImagesRequest(this.path);
}

class OpMergePdfsRequest {
  final List<String> paths;
  OpMergePdfsRequest(this.paths);
}

class OpOpenMergeScreenRequest {}

class OpOpenSplitScreenRequest {
  final String path;
  OpOpenSplitScreenRequest(this.path);
}

class OpOpenDeletePagesRequest {
  final String path;
  OpOpenDeletePagesRequest(this.path);
}

class OpSignPdfRequest {
  final String path;
  OpSignPdfRequest(this.path);
}

class OpShareRequest {
  final String path;
  OpShareRequest(this.path);
}

class OpWordToPdfRequest {
  final String path;
  OpWordToPdfRequest(this.path);
}

class OpExcelToPdfRequest {
  final String path;
  OpExcelToPdfRequest(this.path);
}

class OpImagesToPdfRequest {
  final List<String> paths;
  OpImagesToPdfRequest(this.paths);
}

class OpOcrRequest {
  final String path;
  OpOcrRequest(this.path);
}

class OpOcrBatchRequest {
  final List<String> paths;
  OpOcrBatchRequest(this.paths);
}

class OpBatchRequest {
  final List<String> paths;
  final ConversionType type;
  OpBatchRequest(this.paths, this.type);
}

class OpCompressPdfRequest {
  final String path;
  OpCompressPdfRequest(this.path);
}
