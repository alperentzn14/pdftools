import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfBloc.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfEvent.dart';
import 'package:PDFly/features/pdf/presentation/gradient/primaryButton.dart';

class OCRActionWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: "Resim Seç ve OCR",
      onTap: () async {
        final picker = ImagePicker();
        final image = await picker.pickImage(source: ImageSource.gallery);

        if (image != null) {
          context.read<PdfBloc>().add(ShareFileEvent(image.path));
        }
      },
    );
  }
}
