import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../utils/logger.dart';
import 'dart:convert';

class FileUploadService {
  static const String FILE_UPLOAD_URL =
      "https://files-public.coffeecodes.in/upload";
  static const String API_KEY =
      "fdbf4587fmd,nfa,s#%\$#^WGroei458eofhuahirh218798110`0uwiq";
  static Future<String?> uploadFile(
    String filePath, {
    String? customFileName,
    String? customMimeType,
  }) async {
    if (filePath.isEmpty) return null;

    final file = File(filePath);
    if (!await file.exists()) {
      AppLogger.e("File does not exist at $filePath");
      return null;
    }

    try {
      final url = await _uploadToServer(
        file,
        customFileName: customFileName,
        customMimeType: customMimeType,
      );
      return url;
    } catch (e) {
      AppLogger.e("Error in uploadFile: $e");
      throw e;
    }
  }

  static Future<String?> _uploadToServer(
    File file, {
    String? customFileName,
    String? customMimeType,
  }) async {
    try {
      final uri = Uri.parse(FILE_UPLOAD_URL);
      final request = http.MultipartRequest('POST', uri);

      request.fields['apiKey'] = API_KEY;

      final fileName = customFileName ?? path.basename(file.path);
      //final mimeType = customMimeType ?? _getMimeType(file.path);

      final multipartFile = await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: fileName,
      );

      request.files.add(multipartFile);
      request.headers['Content-Type'] = 'multipart/form-data';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = response.body;

        return _extractUrlFromResponse(responseData);
      } else {
        throw HttpException(
            'Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.e("Error in _uploadToServer: $e");
      throw e;
    }
  }

  static String? _extractUrlFromResponse(String responseBody) {
    try {
      final Map<String, dynamic> data = json.decode(responseBody);
      return data['url'] as String?;
    } catch (e) {
      AppLogger.e("Error extracting URL from response: $e");
      return null;
    }
  }
}
