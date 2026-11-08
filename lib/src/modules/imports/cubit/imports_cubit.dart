import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

import 'imports_state.dart';

class ImportsCubit extends Cubit<ImportsState> {
  ImportsCubit({
    required this.importsRepository,
    required this.clientsRepository,
    required this.suppliersRepository,
  }) : super(const ImportsInitial());

  final ImportsRepository importsRepository;
  final ClientsRepository clientsRepository;
  final SuppliersRepository suppliersRepository;

  Future<ImportResult?> importFile({
    required ImportType type,
    required Uint8List bytes,
    required String fileName,
    required String branchId,
  }) async {
    emit(ImportsLoading(type));

    try {
      final result = await importsRepository.importCsv(
        type: type,
        bytes: bytes,
        fileName: fileName,
        branchId: branchId,
      );

      await _refreshAffectedCatalogs(type);

      emit(ImportsSuccess(type: type, result: result));
      return result;
    } catch (error) {
      emit(ImportsError(type: type, message: _friendlyMessage(error)));
      return null;
    }
  }

  void reset() {
    emit(const ImportsInitial());
  }

  Future<void> _refreshAffectedCatalogs(ImportType type) async {
    try {
      switch (type) {
        case ImportType.clients:
          await clientsRepository.getAllClients();
          break;
        case ImportType.suppliers:
          await suppliersRepository.getAllSuppliers();
          break;
        case ImportType.initialInventory:
        case ImportType.inventory:
          break;
      }
    } catch (_) {
      // La importación ya fue exitosa. Un fallo al refrescar la caché no debe
      // convertir la operación en un error para el usuario.
    }
  }

  String _friendlyMessage(Object error) {
    if (error is HttpServiceException) {
      final detail = error.body['detail'];

      if (detail is String && detail.trim().isNotEmpty) {
        return detail;
      }

      if (detail is List) {
        final messages = detail
            .whereType<Map>()
            .map((item) => item['msg'])
            .whereType<String>()
            .where((message) => message.trim().isNotEmpty)
            .toList();

        if (messages.isNotEmpty) {
          return messages.join("\n");
        }
      }
    }

    return error
        .toString()
        .replaceFirst('HttpServiceException: ', '')
        .replaceFirst('Exception: ', '')
        .replaceFirst('FormatException: ', '');
  }
}
