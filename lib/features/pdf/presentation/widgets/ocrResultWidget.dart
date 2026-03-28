import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfBloc.dart';
import 'package:PDFly/features/pdf/presentation/bloc/pdfState.dart';
import 'package:PDFly/features/pdf/presentation/gradient/appCard.dart';

class OCRResultWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PdfBloc, PdfState>(
      builder: (context, state) {
        if (state is PdfLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (state is PdfSuccess) {
          return AppCard(
            child: SingleChildScrollView(
              child: Text(
                state.filePath,
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        if (state is PdfError) {
          return Text(state.message, style: TextStyle(color: Colors.red));
        }

        return SizedBox();
      },
    );
  }
}
