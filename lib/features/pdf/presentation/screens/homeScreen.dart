import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfconverter/features/pdf/presentation/bloc/pdfBloc.dart';
import 'package:pdfconverter/features/pdf/presentation/bloc/pdfEvent.dart';
import 'package:pdfconverter/features/pdf/presentation/bloc/pdfState.dart';
import 'package:pdfconverter/features/pdf/presentation/gradient/gradientAdBanner.dart';
import 'package:pdfconverter/features/pdf/presentation/screens/batchResultScreen.dart';
import 'package:pdfconverter/features/pdf/presentation/screens/imageResultScreen.dart';
import 'package:pdfconverter/features/pdf/presentation/screens/pdfEditScreen.dart';
import 'package:pdfconverter/features/pdf/presentation/screens/signaturePdfScreen.dart';
import 'package:pdfconverter/features/pdf/presentation/widgets/conversionProgress.dart';
import 'package:pdfconverter/features/pdf/presentation/widgets/filePickerZone.dart';
import 'package:pdfconverter/features/pdf/presentation/widgets/operationList.dart';
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
    setState(() {
      _selectedFiles =
          imagePaths
              .map(
                (p) => PlatformFile(
                  name: p.split('/').last.split('\\').last,
                  path: p,
                  size: 0,
                ),
              )
              .toList();
      _isImages = true;
    });
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
        MaterialPageRoute(builder: (_) => const PdfEditScreen(initialTab: 0)),
      );
    } else if (request is OpOpenSplitScreenRequest) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfEditScreen(initialTab: 1, pdfPath: request.path),
        ),
      );
    } else if (request is OpOpenDeletePagesRequest) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfEditScreen(initialTab: 2, pdfPath: request.path),
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
    }
  }

  void _handleState(BuildContext context, PdfState state) {
    if (state is PdfSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('done'.tr()),
          action: SnackBarAction(
            label: 'open'.tr(),
            onPressed:
                () =>
                    context.read<PdfBloc>().add(OpenFileEvent(state.filePath)),
          ),
          duration: const Duration(seconds: 8),
        ),
      );
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
                        // Dil değiştirme
                        TextButton(
                          onPressed: () {
                            final current = context.locale;
                            context.setLocale(
                              current.languageCode == 'tr'
                                  ? const Locale('en')
                                  : const Locale('tr'),
                            );
                          },
                          child: Text(
                            'change_language'.tr(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Seçili dosya chip'leri
                  if (_selectedFiles.isNotEmpty && !_isProcessing(state))
                    _FileChipsRow(
                      files: _selectedFiles,
                      onClear: _clearSelection,
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
        adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      ),
    );
  }
}

class _FileChipsRow extends StatelessWidget {
  final List<PlatformFile> files;
  final VoidCallback onClear;

  const _FileChipsRow({required this.files, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final label =
        files.length == 1
            ? 'file_selected'.tr()
            : 'files_selected'.tr(
              namedArgs: {'count': files.length.toString()},
            );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.attach_file, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${files.first.name}${files.length > 1 ? " +${files.length - 1}" : ""}  •  $label',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54, size: 18),
            onPressed: onClear,
            tooltip: 'clear'.tr(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
