import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfBloc.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfEvent.dart';
import 'package:PDFly/features/pdf/presentation/gradient/primaryButton.dart';

class ShareButton extends StatelessWidget {
  final String path;

  const ShareButton({required this.path});

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: "Paylaş (WhatsApp dahil)",
      onTap: () {
        context.read<PdfBloc>().add(ShareFileEvent(path));
      },
    );
  }
}
