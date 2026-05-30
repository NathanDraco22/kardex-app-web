import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

part 'export_price_list_state.dart';

class ExportPriceListCubit extends Cubit<ExportPriceListState> {
  ExportPriceListCubit() : super(ExportPriceListInitial());

  Future<void> exportExcel({required String branchName, required String branchId}) async {
    emit(ExportPriceListLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));

      final fileName = "lista_precios_$branchName";

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: fileName,
          fileExtension: "xlsx",
          mimeType: MimeType.microsoftExcel,
            link: LinkDetails(
              link: HttpTools.generateUri("/exports/price-list").toString(),
              headers: {
                "branch-id": branchId,
                ...HttpTools.generateAuthHeaders(),
              },
            ),
          );
        } else {
          await FileSaver.instance.saveAs(
            name: fileName,
            fileExtension: "xlsx",
            mimeType: MimeType.microsoftExcel,
            link: LinkDetails(
              link: HttpTools.generateUri("/exports/price-list").toString(),
              headers: {
                "branch-id": branchId,
                ...HttpTools.generateAuthHeaders(),
              },
            ),
          );
      }

      emit(ExportPriceListSuccess());
    } catch (e) {
      emit(ExportPriceListFailure(message: e.toString()));
    }
  }
}
