import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImageUploadService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<String> uploadImage(XFile image, {String? type}) async {
    try {
      // Create a multipart request
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));

      // Read the image as bytes
      final bytes = await image.readAsBytes();

      // Add the image file to the request
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: path.basename(image.path),
        ),
      );

      // Add type if provided
      if (type != null) {
        request.fields['type'] = type;
      }

      // Send the request
      var response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['filePath'] as String;
      } else {
        print('Upload failed: ${response.statusCode} - $responseBody');
        throw Exception('Failed to upload image: $responseBody');
      }
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Error uploading image: $e');
    }
  }

  static Future<XFile?> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      rethrow;
    }
  }
}
