import 'package:image_picker/image_picker.dart';
import 'package:universal_io/io.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File> pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFile?.path != null) {
      return File(pickedFile!.path);
    } else {
      throw PickGalleryImageException();
    }
  }

  Future<File> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile?.path != null) {
      return File(pickedFile!.path);
    } else {
      throw PickCameraImageException();
    }
  }

  Future<List<File>> pickMultipleImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (pickedFiles.isNotEmpty) {
      return pickedFiles.map((xFile) => File(xFile.path)).toList();
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
