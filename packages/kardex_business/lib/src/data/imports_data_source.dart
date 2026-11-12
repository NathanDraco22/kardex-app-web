import 'dart:typed_data';

import 'package:kardex_business/src/services/http_service.dart';
import 'package:kardex_business/src/tools/http_tool.dart';

class ImportsDataSource with HttpService {
  ImportsDataSource._();
  static final ImportsDataSource instance = ImportsDataSource._();
  factory ImportsDataSource() {
    return instance;
  }

  final _endpoint = "/imports";

  Future<Map<String, dynamic>> importInitialInventory({
    required Uint8List bytes,
    required String fileName,
    required String branchId,
  }) {
    return _importFile(
      "/init-inventory",
      bytes: bytes,
      fileName: fileName,
      branchId: branchId,
    );
  }

  Future<Map<String, dynamic>> importInventory({
    required Uint8List bytes,
    required String fileName,
    required String branchId,
  }) {
    return _importFile(
      "/inventory",
      bytes: bytes,
      fileName: fileName,
      branchId: branchId,
    );
  }

  Future<Map<String, dynamic>> importClients({
    required Uint8List bytes,
    required String fileName,
    required String branchId,
  }) {
    return _importFile(
      "/clients",
      bytes: bytes,
      fileName: fileName,
      branchId: branchId,
    );
  }

  Future<Map<String, dynamic>> importSuppliers({
    required Uint8List bytes,
    required String fileName,
  }) {
    return _importFile("/suppliers", bytes: bytes, fileName: fileName);
  }

  Future<Map<String, dynamic>> previewImport({
    required String type,
    required Uint8List bytes,
    required String fileName,
    String? branchId,
  }) async {
    final uri = HttpTools.generateUri(
      "$_endpoint/preview",
      queryParameters: {"type": type},
    );
    final headers = HttpTools.generateAuthHeaders();

    if (branchId != null) {
      headers["X-Branch"] = branchId;
      headers["branch-id"] = branchId;
    }

    return multipartQuery(
      uri,
      bytes,
      fileName: fileName,
      mediaType: "text/csv",
      headers: headers,
      fieldName: "file",
    );
  }

  Future<Map<String, dynamic>> _importFile(
    String path, {
    required Uint8List bytes,
    required String fileName,
    String? branchId,
  }) async {
    final uri = HttpTools.generateUri("$_endpoint$path");
    final headers = HttpTools.generateAuthHeaders();

    if (branchId != null) {
      headers["X-Branch"] = branchId;
      headers["branch-id"] = branchId;
    }

    return multipartQuery(
      uri,
      bytes,
      fileName: fileName,
      mediaType: "text/csv",
      headers: headers,
      fieldName: "file",
    );
  }
}
