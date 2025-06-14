import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static const String profileFolderPath =
      'C:\\Users\\abeni\\OneDrive\\Desktop\\profile';

  static Future<String> saveImageToLocalFolder(XFile image) async {
    if (kIsWeb) {
      // For web platform, just return the image name
      return image.name;
    }

    try {
      // Create the profile folder if it doesn't exist
      final directory = Directory(profileFolderPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Generate a unique filename
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
      final String filePath = path.join(profileFolderPath, fileName);

      // Copy the image to the profile folder
      final File imageFile = File(image.path);
      await imageFile.copy(filePath);

      return filePath;
    } catch (e) {
      print('Error saving image: $e');
      rethrow;
    }
  }

  static bool isValidImagePath(String imagePath) {
    if (kIsWeb) {
      // For web platform, we don't validate the path
      return true;
    }
    return imagePath.startsWith(profileFolderPath);
  }

  static Future<bool> deleteImage(String imagePath) async {
    if (kIsWeb) {
      // For web platform, we can't delete files
      return true;
    }

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  static Future<XFile?> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    return image;
  }
}
