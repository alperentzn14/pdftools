import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfBloc.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfEvent.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfState.dart';
import 'package:PDFly/features/pdf/presentation/gradient/gradientAdBanner.dart';
import 'package:PDFly/features/pdf/presentation/screens/batchResultScreen.dart';
import 'package:PDFly/features/pdf/presentation/screens/imageResultScreen.dart';
import 'package:PDFly/features/pdf/presentation/screens/pdfEditScreen.dart';
import 'package:PDFly/features/pdf/presentation/screens/signaturePdfScreen.dart';
import 'package:PDFly/features/pdf/presentation/widgets/conversionProgress.dart';
import 'package:PDFly/features/pdf/presentation/widgets/filePickerZone.dart';
import 'package:PDFly/features/pdf/presentation/widgets/operationList.dart';
import 'package:share_plus/share_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PlatformFile> _selectedFiles = [];
  bool _isImages = false;

  void _onFilesPicked(List<PlatformFile> files) {
    setState(() {
      _selectedFiles = files;
      _isImages = false;
    });
  }

  void _onImagesPicked(List<String> imagePaths) {
    final newFiles = imagePaths.map(
      (p) => PlatformFile(
        name: p.split('/').last.split('\\').last,
        path: p,
        size: 0,
      ),
    );
    setState(() {
      if (_isImages) {
        // Mevcut görüntü seçimine ekle (replace etme)
        _selectedFiles = [..._selectedFiles, ...newFiles];
      } else {
        _selectedFiles = newFiles.toList();
        _isImages = true;
      }
    });
  }

  Future<void> _addMoreImages() async {
    final images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) {
      _onImagesPicked(images.map((x) => x.path).toList());
    }
  }

  static const _languages = [
    {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇧🇷'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'hi', 'name': 'हिन्दी', 'flag': '🇮🇳'},
  ];

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final current = context.locale.languageCode;
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.75,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _languages.length,
                  itemBuilder: (_, i) {
                    final lang = _languages[i];
                    final isSelected = lang['code'] == current;
                    return ListTile(
                      leading: Text(
                        lang['flag']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        lang['name']!,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF1E3A8A) : null,
                        ),
                      ),
                      trailing:
                          isSelected
                              ? const Icon(
                                Icons.check,
                                color: Color(0xFF1E3A8A),
                              )
                              : null,
                      onTap: () {
                        context.setLocale(Locale(lang['code']!));
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.paddingOf(ctx).bottom + 8),
            ],
          ),
        );
      },
    );
  }

  void _clearSelection() {
    setState(() {
      _selectedFiles = [];
      _isImages = false;
    });
  }

  void _handleDispatch(dynamic request, BuildContext context) {
    final bloc = context.read<PdfBloc>();

    if (request is OpPdfToWordRequest) {
      bloc.add(PdfToWordEvent(request.path));
    } else if (request is OpAdvancedExcelRequest) {
      bloc.add(AdvancedPdfToExcelEvent(request.path));
    } else if (request is OpPdfToImagesRequest) {
      bloc.add(PdfToImagesEvent(request.path));
    } else if (request is OpMergePdfsRequest) {
      bloc.add(MergePdfsEvent(request.paths));
    } else if (request is OpOpenMergeScreenRequest) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => BlocProvider.value(
                value: bloc,
                child: const PdfEditScreen(initialTab: 0),
              ),
        ),
      );
    } else if (request is OpOpenSplitScreenRequest) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => BlocProvider.value(
                value: bloc,
                child: PdfEditScreen(initialTab: 1, pdfPath: request.path),
              ),
        ),
      );
    } else if (request is OpOpenDeletePagesRequest) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => BlocProvider.value(
                value: bloc,
                child: PdfEditScreen(initialTab: 2, pdfPath: request.path),
              ),
        ),
      );
    } else if (request is OpSignPdfRequest) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SignaturePdfScreen(initialPdfPath: request.path),
        ),
      );
    } else if (request is OpShareRequest) {
      Share.shareXFiles([XFile(request.path)]);
    } else if (request is OpWordToPdfRequest) {
      bloc.add(WordToPdfEvent(request.path));
    } else if (request is OpExcelToPdfRequest) {
      bloc.add(ExcelToPdfEvent(request.path));
    } else if (request is OpImagesToPdfRequest) {
      bloc.add(ImagesToPdfEvent(request.paths));
    } else if (request is OpOcrRequest) {
      bloc.add(OCRToPdfEvent(request.path));
    } else if (request is OpOcrBatchRequest) {
      bloc.add(OCRBatchEvent(request.paths));
    } else if (request is OpBatchRequest) {
      bloc.add(BatchConvertEvent(request.paths, request.type));
    } else if (request is OpCompressPdfRequest) {
      _showCompressionPicker(context, request.path);
    }
  }

  void _showCompressionPicker(BuildContext context, String pdfPath) {
    final bloc = context.read<PdfBloc>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'compress.title'.tr(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _compressionTile(
                  ctx,
                  bloc,
                  pdfPath,
                  0,
                  'compress.light'.tr(),
                  'compress.light_sub'.tr(),
                  Icons.compress,
                  Colors.green,
                ),
                _compressionTile(
                  ctx,
                  bloc,
                  pdfPath,
                  1,
                  'compress.medium'.tr(),
                  'compress.medium_sub'.tr(),
                  Icons.compress,
                  Colors.orange,
                ),
                _compressionTile(
                  ctx,
                  bloc,
                  pdfPath,
                  2,
                  'compress.max'.tr(),
                  'compress.max_sub'.tr(),
                  Icons.compress,
                  Colors.red,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }

  Widget _compressionTile(
    BuildContext ctx,
    PdfBloc bloc,
    String path,
    int level,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      onTap: () {
        Navigator.pop(ctx);
        bloc.add(CompressPdfEvent(path, level));
      },
    );
  }

  void _showSuccessDialog(BuildContext context, String filePath) {
    final fileName = filePath.split('/').last.split('\\').last;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 48),
        title: Text('done'.tr()),
        content: Text(
          fileName,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<PdfBloc>().add(OpenFileEvent(filePath));
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text('open'.tr()),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              Share.shareXFiles([XFile(filePath)]);
            },
            icon: const Icon(Icons.share, size: 18),
            label: Text('share'.tr()),
          ),
        ],
      ),
    );
  }

  void _handleState(BuildContext context, PdfState state) {
    if (state is PdfSuccess) {
      _showSuccessDialog(context, state.filePath);
    } else if (state is PdfError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'cancel'.tr(),
            textColor: Colors.white,
            onPressed:
                () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          ),
        ),
      );
    } else if (state is PdfBatchSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => BlocProvider.value(
                value: context.read<PdfBloc>(),
                child: BatchResultScreen(filePaths: state.filePaths),
              ),
        ),
      );
    } else if (state is PdfMultiImageSuccess) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImageResultScreen(imagePaths: state.imagePaths),
        ),
      );
    }
  }

  bool _isProcessing(PdfState state) =>
      state is PdfLoading || state is PdfBatchProgress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF7C3AED)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<PdfBloc, PdfState>(
            listener: _handleState,
            builder: (context, state) {
              return Column(
                children: [
                  // AppBar area
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'app_title'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.language,
                            color: Colors.white70,
                          ),
                          tooltip: 'change_language'.tr(),
                          onPressed: () => _showLanguagePicker(context),
                        ),
                      ],
                    ),
                  ),

                  // Seçili dosya chip'leri
                  if (_selectedFiles.isNotEmpty && !_isProcessing(state))
                    _FileChipsRow(
                      files: _selectedFiles,
                      isImages: _isImages,
                      onClear: _clearSelection,
                      onAddMore: _addMoreImages,
                    ),

                  // Ana içerik
                  Expanded(
                    child:
                        _isProcessing(state)
                            ? ConversionProgress(state: state)
                            : _selectedFiles.isEmpty
                            ? FilePickerZone(
                              onFilesPicked: _onFilesPicked,
                              onImagesPicked: _onImagesPicked,
                            )
                            : OperationList(
                              files: _selectedFiles,
                              isImages: _isImages,
                              onDispatch:
                                  (req) => _handleDispatch(req, context),
                            ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: GradientAdBanner(
        adUnitId: 'ca-app-pub-2693603012319986~7354830774',
      ),
    );
  }
}

class _FileChipsRow extends StatelessWidget {
  final List<PlatformFile> files;
  final bool isImages;
  final VoidCallback onClear;
  final VoidCallback onAddMore;

  const _FileChipsRow({
    required this.files,
    required this.isImages,
    required this.onClear,
    required this.onAddMore,
  });

  IconData _fileIcon(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'webp':
      case 'heic':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _fileColor(String name) {
    final ext = name.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf':
        return const Color(0xFFD32F2F);
      case 'doc':
      case 'docx':
        return const Color(0xFF1565C0);
      case 'xls':
      case 'xlsx':
        return const Color(0xFF2E7D32);
      default:
        return const Color(0xFFE65100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = files.length;
    final label =
        count == 1
            ? 'file_selected'.tr()
            : 'files_selected'.tr(
              namedArgs: {'count': count.toString()},
            );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Row(
        children: [
          // Dosya tipi ikonu
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _fileColor(files.first.name).withAlpha(50),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _fileIcon(files.first.name),
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          // Dosya bilgileri
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  files.first.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  count > 1 ? '$label  (+${count - 1})' : label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          // Görüntü seçiliyse "+" butonu
          if (isImages)
            _actionButton(
              icon: Icons.add_photo_alternate,
              onPressed: onAddMore,
              tooltip: 'pick_image'.tr(),
            ),
          const SizedBox(width: 4),
          _actionButton(
            icon: Icons.close,
            onPressed: onClear,
            tooltip: 'clear'.tr(),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Material(
      color: Colors.white.withAlpha(20),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: Colors.white70, size: 18),
        ),
      ),
    );
  }
}
