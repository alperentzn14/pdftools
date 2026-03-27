import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfconverter/features/pdf/presentation/bloc/pdfBloc.dart';
import 'package:pdfconverter/features/pdf/presentation/bloc/pdfEvent.dart';
import 'package:share_plus/share_plus.dart';

class BatchResultScreen extends StatelessWidget {
  final List<String> filePaths;

  const BatchResultScreen({super.key, required this.filePaths});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('batch.result_title'.tr()),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'batch.share_all'.tr(),
            onPressed: () => Share.shareXFiles(filePaths.map((p) => XFile(p)).toList()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'batch.files_done'.tr(namedArgs: {'count': filePaths.length.toString()}),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filePaths.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, i) {
                final path = filePaths[i];
                final name = path.split('/').last.split('\\').last;
                return ListTile(
                  leading: const Icon(Icons.insert_drive_file, color: Color(0xFF1E3A8A)),
                  title: Text(name, overflow: TextOverflow.ellipsis),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.open_in_new, size: 20),
                        tooltip: 'open'.tr(),
                        onPressed: () => context.read<PdfBloc>().add(OpenFileEvent(path)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, size: 20),
                        tooltip: 'share'.tr(),
                        onPressed: () => Share.shareXFiles([XFile(path)]),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Share.shareXFiles(filePaths.map((p) => XFile(p)).toList()),
                icon: const Icon(Icons.share),
                label: Text('batch.share_all'.tr()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
