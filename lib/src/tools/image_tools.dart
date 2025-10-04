import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

Future<String> xFileToBase64(XFile file) async {
  final Uint8List imageBytes = await file.readAsBytes();
  final String base64String = base64Encode(imageBytes);
  return base64String;
}

Uint8List base64ToBytes(String base64String) {
  return base64Decode(base64String);
}
