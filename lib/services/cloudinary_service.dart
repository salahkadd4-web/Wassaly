import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../core/constants/app_config.dart';

class CloudinaryException implements Exception {
  CloudinaryException(this.message);

  final String message;

  @override
  String toString() => 'CloudinaryException: $message';
}

/// Envoi d'images vers Cloudinary en mode "unsigned" (sans secret dans l'app).
class CloudinaryService {
  CloudinaryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static bool get isConfigured =>
      AppConfig.cloudinaryCloudName != 'A_RENSEIGNER' &&
      AppConfig.cloudinaryUploadPreset != 'A_RENSEIGNER';

  /// Envoie [file] et renvoie l'URL https de l'image.
  Future<String> uploadImage(XFile file) async {
    try {
      return await _upload(file);
    } on CloudinaryException {
      rethrow;
    } catch (e) {
      // Reseau coupe, delai depasse, fichier illisible...
      throw CloudinaryException('$e');
    }
  }

  Future<String> _upload(XFile file) async {
    if (!isConfigured) {
      throw CloudinaryException('Cloudinary non configure (app_config.dart).');
    }
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/image/upload',
    );
    final bytes = await file.readAsBytes();
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConfig.cloudinaryUploadPreset
      ..fields['folder'] = AppConfig.cloudinaryIdFolder
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: 'id.jpg'),
      );

    final streamed =
        await _client.send(request).timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);

    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {}

    if (response.statusCode != 200 || body == null) {
      final err = (body?['error'] as Map?)?['message'];
      throw CloudinaryException(
        'HTTP ${response.statusCode}${err != null ? ' : $err' : ''}',
      );
    }
    final url = body['secure_url'] as String?;
    if (url == null || url.isEmpty) {
      throw CloudinaryException('Reponse sans secure_url.');
    }
    return url;
  }
}
