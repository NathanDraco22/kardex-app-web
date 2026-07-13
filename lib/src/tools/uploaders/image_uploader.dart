import 'dart:typed_data';

import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

class _ImageUploaderService with HttpService {}

class ImageUploader {
  static final _service = _ImageUploaderService();

  static const String _servinCoreUrl = String.fromEnvironment("ORIGIN_SERVER_URL", defaultValue: "");

  static Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String mediaType = "image/jpeg",
  }) async {
    final authCubit = getIt.get<AuthCubit>();
    final nickname = authCubit.servin?.nickname;

    if (nickname == null) {
      throw StateError("No active servin session found.");
    }

    final uri = Uri.parse("$_servinCoreUrl/api/v1/images/upload/neptuno/$nickname");
    final headers = HttpTools.generateAuthHeaders();

    final response = await _service.multipartQuery(
      uri,
      bytes,
      fileName: fileName,
      mediaType: mediaType,
      headers: headers,
      fieldName: "image",
    );

    final url = response['url'] as String?;
    if (url == null) {
      throw Exception("Failed to retrieve image URL from upload response.");
    }

    return url;
  }
}
