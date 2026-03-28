import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfBloc.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfEvent.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfState.dart';
import 'package:PDFly/features/pdf/presentation/screens/batchResultScreen.dart';

class PdfEditScreen extends StatefulWidget {
  final int initialTab;
  final String? pdfPath;

  const PdfEditScreen({super.key, required this.initialTab, this.pdfPath});

  @override
  State<PdfEditScreen> createState() => _PdfEditScreenState();
}

class _PdfEditScreenState extends State<PdfEditScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Merge tab
  List<String> _mergePaths = [];

  // Split tab
  String? _splitPath;
  final _splitController = TextEditingController();

  // Delete pages tab
  String? _deletePath;
  final _deleteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    if (widget.pdfPath != null) {
      _splitPath = widget.pdfPath;
      _deletePath = widget.pdfPath;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _splitController.dispose();
    _deleteController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfForMerge() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _mergePaths.addAll(
          result.files.map((f) => f.path ?? '').where((p) => p.isNotEmpty),
        );
      });
    }
  }

  Future<void> _pickPdfSingle(ValueSetter<String> onPicked) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      onPicked(result.files.single.path!);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade700),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PdfBloc, PdfState>(
      listener: (context, state) {
        if (state is PdfSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('edit.done'.tr()),
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'open'.tr(),
                onPressed:
                    () => context.read<PdfBloc>().add(
                      OpenFileEvent(state.filePath),
                    ),
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
        } else if (state is PdfError) {
          _showError(state.message);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('edit.title'.tr()),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            indicatorColor: const Color(0xFF7C3AED),
            tabs: [
              Tab(text: 'edit.merge'.tr()),
              Tab(text: 'edit.split'.tr()),
              Tab(text: 'edit.delete_pages'.tr()),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _MergeTab(
              paths: _mergePaths,
              onAdd: _pickPdfForMerge,
              onRemove: (i) => setState(() => _mergePaths.removeAt(i)),
              onMerge: () {
                if (_mergePaths.length < 2) {
                  _showError('edit.merge_min'.tr());
                  return;
                }
                context.read<PdfBloc>().add(MergePdfsEvent(_mergePaths));
              },
            ),
            _SplitTab(
              pdfPath: _splitPath,
              controller: _splitController,
              onPickPdf:
                  () => _pickPdfSingle((p) => setState(() => _splitPath = p)),
              onSplit: () {
                if (_splitPath == null) {
                  _showError('edit.pick_pdf_first'.tr());
                  return;
                }
                final pages =
                    _splitController.text
                        .trim()
                        .split(',')
                        .map((s) => int.tryParse(s.trim()))
                        .whereType<int>()
                        .toList();
                if (pages.isEmpty) {
                  _showError('edit.split_hint_error'.tr());
                  return;
                }
                context.read<PdfBloc>().add(SplitPdfEvent(_splitPath!, pages));
              },
            ),
            _DeleteTab(
              pdfPath: _deletePath,
              controller: _deleteController,
              onPickPdf:
                  () => _pickPdfSingle((p) => setState(() => _deletePath = p)),
              onDelete: () {
                if (_deletePath == null) {
                  _showError('edit.pick_pdf_first'.tr());
                  return;
                }
                final pages =
                    _deleteController.text
                        .trim()
                        .split(',')
                        .map((s) => int.tryParse(s.trim()))
                        .whereType<int>()
                        .where((p) => p >= 1)
                        .map(
                          (p) => p - 1,
                        ) // convert 1-based user input → 0-based index
                        .toList();
                if (pages.isEmpty) {
                  _showError('edit.delete_hint_error'.tr());
                  return;
                }
                context.read<PdfBloc>().add(
                  DeletePagesEvent(_deletePath!, pages),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MergeTab extends StatelessWidget {
  final List<String> paths;
  final VoidCallback onAdd;
  final void Function(int) onRemove;
  final VoidCallback onMerge;

  const _MergeTab({
    required this.paths,
    required this.onAdd,
    required this.onRemove,
    required this.onMerge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child:
                paths.isEmpty
                    ? Center(
                      child: Text(
                        'edit.merge_empty'.tr(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                    : ListView.separated(
                      itemCount: paths.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder:
                          (_, i) => ListTile(
                            leading: const Icon(
                              Icons.picture_as_pdf,
                              color: Color(0xFF1E3A8A),
                            ),
                            title: Text(
                              paths[i].split('/').last.split('\\').last,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => onRemove(i),
                            ),
                          ),
                    ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add),
                  label: Text('edit.add_pdf'.tr()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onMerge,
                  icon: const Icon(Icons.merge_type),
                  label: Text('edit.merge'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SplitTab extends StatelessWidget {
  final String? pdfPath;
  final TextEditingController controller;
  final VoidCallback onPickPdf;
  final VoidCallback onSplit;

  const _SplitTab({
    required this.pdfPath,
    required this.controller,
    required this.onPickPdf,
    required this.onSplit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PdfPickRow(pdfPath: pdfPath, onPick: onPickPdf),
          const SizedBox(height: 16),
          Text(
            'edit.split_after_pages'.tr(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'edit.split_hint'.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSplit,
              icon: const Icon(Icons.call_split),
              label: Text('edit.split'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteTab extends StatelessWidget {
  final String? pdfPath;
  final TextEditingController controller;
  final VoidCallback onPickPdf;
  final VoidCallback onDelete;

  const _DeleteTab({
    required this.pdfPath,
    required this.controller,
    required this.onPickPdf,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PdfPickRow(pdfPath: pdfPath, onPick: onPickPdf),
          const SizedBox(height: 16),
          Text(
            'edit.pages_to_delete'.tr(),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'edit.delete_hint'.tr(),
              border: const OutlineInputBorder(),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              label: Text('edit.delete_pages'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfPickRow extends StatelessWidget {
  final String? pdfPath;
  final VoidCallback onPick;

  const _PdfPickRow({required this.pdfPath, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final name =
        pdfPath != null
            ? pdfPath!.split('/').last.split('\\').last
            : 'edit.no_pdf'.tr();
    return InkWell(
      onTap: onPick,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF1E3A8A)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.picture_as_pdf, color: Color(0xFF1E3A8A)),
            const SizedBox(width: 12),
            Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
            const Icon(Icons.folder_open, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
