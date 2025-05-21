import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mjollnir/core/api/api_constants.dart';
import 'dart:convert';
import '../../shared/components/logger/logger.dart';
import '../storage/local_storage.dart';

enum ImageType {
  avatar,
  banner;

  String get value {
    switch (this) {
      case ImageType.avatar:
        return 'avatar';
      case ImageType.banner:
        return 'banner';
    }
  }
}

class ImageService {
  ImageService._();
  static final ImagePicker _picker = ImagePicker();
  static final LocalStorage _storage = LocalStorage();

  static Future<String?> pickAndUploadImage({
    required ImageType type,
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Added quality parameter for optimization
      );

      if (pickedFile == null) {
        Logger.i('No image selected');
        return null;
      }

      Logger.i('Image picked: ${pickedFile.path}');
      return await _uploadImage(pickedFile, type);
    } catch (e) {
      Logger.e('Error in pickAndUploadImage: $e');
      return null;
    }
  }

  static Future<String?> _uploadImage(XFile file, ImageType type) async {
    try {
      final url = '${ApiConstants.baseUrl}/v1/files/upload?type=${type.value}';
      Logger.d('Uploading to: $url');

      var request = http.MultipartRequest('POST', Uri.parse(url));
      var fileBytes = await file.readAsBytes();
      var fileName = file.path.split('/').last;
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ));

      final token = await _storage.getToken();
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
      if (kDebugMode) {
        _logRequestDetails(request, fileName, fileBytes.length);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        Logger.d('HTTP Response Status: ${response.statusCode}');
        Logger.d('HTTP Response Body: ${response.body}');
      }
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = json.decode(response.body);
        String imageUrl = responseData['data'] ?? '';
        Logger.i('Image uploaded successfully: $imageUrl');
        return imageUrl;
      } else {
        Logger.e('Failed to upload image. Status code: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      Logger.e('Error uploading image: $e');
      return null;
    }
  }

  static void _logRequestDetails(
    http.MultipartRequest request,
    String fileName,
    int fileSize,
  ) {
    Logger.d('HTTP Request: ${request.method} ${request.url}');
    Logger.d('HTTP Headers: ${request.headers}');
    Logger.d('HTTP File name: $fileName, size: $fileSize bytes');
  }
}
