import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/models/car_ad.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import '../../presentation/app/di/locator.dart';

class ImageUploadService {
  final String baseUrl;
  final Dio dio;

  ImageUploadService({String? baseUrl, Dio? dio}) : baseUrl = baseUrl ?? ApiConfig.baseUrl, dio = dio ?? locator<Dio>();

  Future<File> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 80,
      minWidth: 1280,
      minHeight: 720,
      format: CompressFormat.jpeg,
    );

    if (result == null) {
      throw Exception('Failed to compress image ${file.path}');
    }

    return File(result.path);
  }

  Future<List<String>> uploadImages(List<File> images, Map<String, dynamic> adData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in. Cannot upload images.');
    }
    final token = await user.getIdToken();

    final List<File> compressedImages = [];
    try {
      for (var imageFile in images) {
        final compressedFile = await _compressImage(imageFile);
        compressedImages.add(compressedFile);
      }

      final formData = FormData.fromMap({
        'data': jsonEncode(adData),
        'images': [
          for (var image in compressedImages)
            await MultipartFile.fromFile(image.path, filename: image.path.split('/').last, contentType: MediaType.parse(_getMimeType(image.path))),
        ],
      });

      final response = await dio.post(
        '$baseUrl/ads',
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }),
      );
      if (response.statusCode == 200) {
        final jsonResponse = response.data as Map<String, dynamic>;
        final carAd = CarAd.fromJson(jsonResponse);
        return carAd.imageUrls;
      } else {
        throw Exception('Failed to upload images: \\${response.statusCode} \\${response.data}');
      }
    } finally {
      for (var file in compressedImages) {
        await file.delete();
      }
    }
  }

  String _getMimeType(String path) {
    final extension = path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        return 'application/octet-stream';
    }
  }
} 