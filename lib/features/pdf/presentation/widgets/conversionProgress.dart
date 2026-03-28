import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfState.dart';

class ConversionProgress extends StatelessWidget {
  final PdfState state;

  const ConversionProgress({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is PdfBatchProgress) {
      final s = state as PdfBatchProgress;
      final progress = s.total > 0 ? s.completed / s.total : 0.0;
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'processing'.tr(),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 24),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white24,
                color: const Color(0xFF7C3AED),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              Text(
                'batch_progress'.tr(
                  namedArgs: {
                    'completed': s.completed.toString(),
                    'total': s.total.toString(),
                  },
                ),
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              if (s.currentFileName.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  s.currentFileName,
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      );
    }

    // PdfLoading
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 16),
          Text(
            'processing'.tr(),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
