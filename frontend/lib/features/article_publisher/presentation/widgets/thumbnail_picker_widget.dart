import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ThumbnailPickerWidget extends StatelessWidget {
  final Uint8List? selectedImageBytes;
  final VoidCallback onTap;

  const ThumbnailPickerWidget({
    Key? key,
    required this.selectedImageBytes,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
          image: selectedImageBytes != null
              ? DecorationImage(
                  image: MemoryImage(selectedImageBytes!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: selectedImageBytes == null ? _buildPlaceholder() : null,
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_photo_alternate_outlined,
            size: 48, color: Color(0xFF8B8B8B)),
        SizedBox(height: 8),
        Text(
          'Tap to add thumbnail',
          style: TextStyle(color: Color(0xFF8B8B8B), fontSize: 14),
        ),
      ],
    );
  }
}

class ThumbnailPickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<ThumbnailPickResult?> pickFromGallery() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();
    return ThumbnailPickResult(bytes: bytes, fileName: picked.name);
  }
}

class ThumbnailPickResult {
  final Uint8List bytes;
  final String fileName;

  const ThumbnailPickResult({required this.bytes, required this.fileName});
}
