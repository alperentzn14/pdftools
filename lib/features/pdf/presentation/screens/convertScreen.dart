import 'package:flutter/material.dart';
import 'package:PDFly/features/pdf/presentation/gradient/appCard.dart';
import 'package:PDFly/features/pdf/presentation/gradient/gradientScaffold.dart';
import 'package:PDFly/features/pdf/presentation/gradient/primaryButton.dart';
import 'package:PDFly/features/pdf/presentation/widgets/filePickerWidget.dart';

class ConvertScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      title: "Convert to PDF",
      child: Column(
        children: [
          FilePickerWidget(
            onPicked: (path) {
              print(path);
            },
          ),

          AppCard(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    "Page Size",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ListTile(
                  title: Text(
                    "Orientation",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ListTile(
                  title: Text("Quality", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          Spacer(),

          PrimaryButton(text: "Convert to PDF", onTap: () {}),
        ],
      ),
    );
  }
}
