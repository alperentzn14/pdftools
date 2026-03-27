import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdfconverter/features/pdf/domain/repositories/pdfRepository.dart';

enum _FileCategory { pdf, word, excel, image, mixed }

class _OpItem {
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final String estSec;
  final VoidCallback onTap;

  const _OpItem({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.estSec,
    required this.onTap,
  });
}

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

    final extensions = files.map((f) {
      final ext = (f.extension ?? '').toLowerCase();
      return ext;
    }).toSet();

    if (extensions.length > 1) return _FileCategory.mixed;
    final ext = extensions.first;
    if (ext == 'pdf') return _FileCategory.pdf;
    if (ext == 'doc' || ext == 'docx') return _FileCategory.word;
    if (ext == 'xls' || ext == 'xlsx') return _FileCategory.excel;
    return _FileCategory.mixed;
  }

  List<_OpItem> _buildOps() {
    final cat = _detectCategory();
    final paths = files.map((f) => f.path ?? '').where((p) => p.isNotEmpty).toList();
    final isMulti = files.length > 1;

    switch (cat) {
      case _FileCategory.pdf:
        if (isMulti) {
          return [
            _OpItem(
              icon: Icons.merge_type,
              titleKey: 'ops.merge_pdf',
              subtitleKey: 'ops.merge_pdf_sub',
              estSec: '3',
              onTap: () => onDispatch(OpMergePdfsRequest(paths)),
            ),
            _OpItem(
              icon: Icons.swap_horiz,
              titleKey: 'ops.batch_convert',
              subtitleKey: 'ops.batch_convert_sub',
              estSec: '5',
              onTap: () => onDispatch(
                OpBatchRequest(paths, ConversionType.pdfToWord),
              ),
            ),
          ];
        }
        final path = paths.first;
        return [
          _OpItem(
            icon: Icons.description,
            titleKey: 'ops.pdf_to_word',
            subtitleKey: 'ops.pdf_to_word_sub',
            estSec: '2',
            onTap: () => onDispatch(OpPdfToWordRequest(path)),
          ),
          _OpItem(
            icon: Icons.table_chart,
            titleKey: 'ops.pdf_to_excel',
            subtitleKey: 'ops.pdf_to_excel_sub',
            estSec: '3',
            onTap: () => onDispatch(OpAdvancedExcelRequest(path)),
          ),
          _OpItem(
            icon: Icons.image_outlined,
            titleKey: 'ops.pdf_to_image',
            subtitleKey: 'ops.pdf_to_image_sub',
            estSec: '4',
            onTap: () => onDispatch(OpPdfToImagesRequest(path)),
          ),
          _OpItem(
            icon: Icons.merge_type,
            titleKey: 'ops.merge_pdf',
            subtitleKey: 'ops.merge_pdf_sub',
            estSec: '3',
            onTap: () => onDispatch(OpOpenMergeScreenRequest()),
          ),
          _OpItem(
            icon: Icons.call_split,
            titleKey: 'ops.split_pdf',
            subtitleKey: 'ops.split_pdf_sub',
            estSec: '2',
            onTap: () => onDispatch(OpOpenSplitScreenRequest(path)),
          ),
          _OpItem(
            icon: Icons.delete_outline,
            titleKey: 'ops.delete_pages',
            subtitleKey: 'ops.delete_pages_sub',
            estSec: '2',
            onTap: () => onDispatch(OpOpenDeletePagesRequest(path)),
          ),
          _OpItem(
            icon: Icons.draw,
            titleKey: 'ops.sign_pdf',
            subtitleKey: 'ops.sign_pdf_sub',
            estSec: '2',
            onTap: () => onDispatch(OpSignPdfRequest(path)),
          ),
          _OpItem(
            icon: Icons.share,
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
              icon: Icons.picture_as_pdf,
              titleKey: 'ops.batch_convert',
              subtitleKey: 'ops.batch_convert_sub',
              estSec: '5',
              onTap: () => onDispatch(
                OpBatchRequest(paths, ConversionType.wordToPdf),
              ),
            ),
          ];
        }
        return [
          _OpItem(
            icon: Icons.picture_as_pdf,
            titleKey: 'ops.word_to_pdf',
            subtitleKey: 'ops.word_to_pdf_sub',
            estSec: '2',
            onTap: () => onDispatch(OpWordToPdfRequest(paths.first)),
          ),
        ];

      case _FileCategory.excel:
        return [
          _OpItem(
            icon: Icons.picture_as_pdf,
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
            icon: Icons.picture_as_pdf,
            titleKey: 'ops.image_to_pdf',
            subtitleKey: 'ops.image_to_pdf_sub',
            estSec: '2',
            onTap: () => onDispatch(OpImagesToPdfRequest(imgPaths)),
          ),
          _OpItem(
            icon: Icons.document_scanner,
            titleKey: 'ops.ocr_to_pdf',
            subtitleKey: 'ops.ocr_to_pdf_sub',
            estSec: '3',
            onTap: () => imgPaths.length == 1
                ? onDispatch(OpOcrRequest(imgPaths.first))
                : onDispatch(OpOcrBatchRequest(imgPaths)),
          ),
        ];

      case _FileCategory.mixed:
        return [
          _OpItem(
            icon: Icons.share,
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
      itemBuilder: (context, i) {
        final op = ops[i];
        return _OperationTile(op: op);
      },
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
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF1E3A8A)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(op.icon, color: Colors.white, size: 22),
              ),
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
class OpPdfToWordRequest { final String path; OpPdfToWordRequest(this.path); }
class OpAdvancedExcelRequest { final String path; OpAdvancedExcelRequest(this.path); }
class OpPdfToImagesRequest { final String path; OpPdfToImagesRequest(this.path); }
class OpMergePdfsRequest { final List<String> paths; OpMergePdfsRequest(this.paths); }
class OpOpenMergeScreenRequest {}
class OpOpenSplitScreenRequest { final String path; OpOpenSplitScreenRequest(this.path); }
class OpOpenDeletePagesRequest { final String path; OpOpenDeletePagesRequest(this.path); }
class OpSignPdfRequest { final String path; OpSignPdfRequest(this.path); }
class OpShareRequest { final String path; OpShareRequest(this.path); }
class OpWordToPdfRequest { final String path; OpWordToPdfRequest(this.path); }
class OpExcelToPdfRequest { final String path; OpExcelToPdfRequest(this.path); }
class OpImagesToPdfRequest { final List<String> paths; OpImagesToPdfRequest(this.paths); }
class OpOcrRequest { final String path; OpOcrRequest(this.path); }
class OpOcrBatchRequest { final List<String> paths; OpOcrBatchRequest(this.paths); }
class OpBatchRequest {
  final List<String> paths;
  final ConversionType type;
  OpBatchRequest(this.paths, this.type);
}
