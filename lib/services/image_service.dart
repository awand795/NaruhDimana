import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  Future<String?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: AppConstants.maxImageWidth.toDouble(),
      imageQuality: AppConstants.maxImageQuality,
    );
    if (image == null) return null;
    return await _compressAndSave(image.path);
  }

  Future<String?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: AppConstants.maxImageWidth.toDouble(),
      imageQuality: AppConstants.maxImageQuality,
    );
    if (image == null) return null;
    return await _compressAndSave(image.path);
  }

  Future<List<String>> pickMultipleFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: AppConstants.maxImageWidth.toDouble(),
      imageQuality: AppConstants.maxImageQuality,
    );
    if (images.isEmpty) return [];

    final List<String> savedPaths = [];
    for (final image in images) {
      final savedPath = await _compressAndSave(image.path);
      if (savedPath != null) savedPaths.add(savedPath);
    }
    return savedPaths;
  }

  Future<void> deleteImages(List<String>? paths) async {
    if (paths == null || paths.isEmpty) return;
    for (final path in paths) {
      await deleteImage(path);
    }
  }

  Future<String?> _compressAndSave(String sourcePath) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'item_${_uuid.v4()}.jpg';
      final targetPath = '${dir.path}/$fileName';

      final result = await FlutterImageCompress.compressAndGetFile(
        sourcePath,
        targetPath,
        minWidth: 800,
        minHeight: 0,
        quality: AppConstants.maxImageQuality,
        format: CompressFormat.jpeg,
      );

      return result?.path ?? sourcePath;
    } catch (e) {
      return sourcePath;
    }
  }

  Future<void> deleteImage(String? path) async {
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<File?> getImageFile(String? path) async {
    if (path == null || path.isEmpty) return null;
    try {
      final file = File(path);
      if (await file.exists()) return file;
      return null;
    } catch (_) {
      return null;
    }
  }
}
