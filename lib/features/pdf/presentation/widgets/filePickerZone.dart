import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FilePickerZone extends StatelessWidget {
  final void Function(List<PlatformFile> files) onFilesPicked;
  final void Function(List<String> imagePaths) onImagesPicked;

  const FilePickerZone({
    super.key,
    required this.onFilesPicked,
    required this.onImagesPicked,
  });

  Future<void> _pickFiles(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
    );
    if (result != null && result.files.isNotEmpty) {
      onFilesPicked(result.files);
    }
  }

  Future<void> _pickImages(BuildContext context) async {
    final images = await ImagePicker().pickMultiImage();
    if (images.isNotEmpty) {
      onImagesPicked(images.map((x) => x.path).toList());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dashed drop zone
        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(vertical: 36),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white38,
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withAlpha(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.upload_file, color: Colors.white70, size: 52),
              const SizedBox(height: 12),
              Text(
                'no_file_selected'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'no_file_desc'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Dosya seç butonu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _pickFiles(context),
              icon: const Icon(Icons.folder_open),
              label: Text('pick_files'.tr()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Resim seç butonu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickImages(context),
              icon: const Icon(Icons.image_outlined),
              label: Text('pick_image'.tr()),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white38),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
