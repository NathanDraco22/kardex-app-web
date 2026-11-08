import 'dart:typed_data';

import 'package:kardex_business/src/data/imports_data_source.dart';
import 'package:kardex_business/src/domain/models/imports/import_result.dart';
import 'package:kardex_business/src/domain/models/imports/import_type.dart';

class ImportsRepository {
  ImportsRepository(this.importsDataSource);

  final ImportsDataSource importsDataSource;

  Future<ImportResult> importCsv({
    required ImportType type,
    required Uint8List bytes,
    required String fileName,
    required String branchId,
  }) async {
    final response = switch (type) {
      ImportType.initialInventory =>
        await importsDataSource.importInitialInventory(
          bytes: bytes,
          fileName: fileName,
          branchId: branchId,
        ),
      ImportType.inventory => await importsDataSource.importInventory(
        bytes: bytes,
        fileName: fileName,
        branchId: branchId,
      ),
      ImportType.clients => await importsDataSource.importClients(
        bytes: bytes,
        fileName: fileName,
        branchId: branchId,
      ),
      ImportType.suppliers => await importsDataSource.importSuppliers(
        bytes: bytes,
        fileName: fileName,
      ),
    };

    return ImportResult.fromJson(response);
  }
}
