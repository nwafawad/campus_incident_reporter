import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../utils/constants.dart';

/// Uploads incident photos to Cloudinary and returns their links.
class StorageService {
  final _url = Uri.parse(
    'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/image/upload',
  );

  Future<String> uploadPhoto(XFile photo, String incidentId) async {
    final request = http.MultipartRequest('POST', _url)
      ..fields['upload_preset'] = cloudinaryUploadPreset
      ..fields['folder'] = 'campuscare/incidents/$incidentId'
      ..files.add(await http.MultipartFile.fromPath('file', photo.path));

    final response = await http.Response.fromStream(await request.send());
    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(body['error']?['message'] ?? 'Photo upload failed');
    }
    return body['secure_url'];
  }

  Future<List<String>> uploadPhotos(List<XFile> photos, String incidentId) =>
      Future.wait(photos.map((p) => uploadPhoto(p, incidentId)));
}
