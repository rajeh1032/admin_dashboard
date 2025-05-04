import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<XFile> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile?.path != null) {
      return XFile(pickedFile!.path);
    } else {
      throw PickGalleryImageException();
    }
  }

  Future<XFile> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile?.path != null) {
      return XFile(pickedFile!.path);
    } else {
      throw PickCameraImageException();
    }
  }

  Future<List<XFile>> pickMultipleImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFiles.isNotEmpty) {
      return pickedFiles.map((xFile) => XFile(xFile.path)).toList();
    } else {
      throw PickMultiImageException();
    }
  }
}

class PickGalleryImageException implements Exception {
  final String message = 'Failed to pick image from gallery.';
}

class PickCameraImageException implements Exception {
  final String message = 'Failed to pick image from camera.';
}

class PickMultiImageException implements Exception {
  final String message = 'Failed to pick multiple images.';
}
