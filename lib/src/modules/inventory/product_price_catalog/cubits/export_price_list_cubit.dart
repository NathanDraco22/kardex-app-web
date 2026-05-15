import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

part 'export_price_list_state.dart';

class ExportPriceListCubit extends Cubit<ExportPriceListState> {
  ExportPriceListCubit() : super(ExportPriceListInitial());

  Future<void> exportExcel() async {
    emit(ExportPriceListLoading());
    try {
      await Future.delayed(const Duration(seconds: 1));

      final fileName = "lista_precios_${BranchesTool.getCurrentBranch()?.name}";

      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: fileName,
          fileExtension: "xlsx",
          mimeType: MimeType.microsoftExcel,
          link: LinkDetails(
            link: HttpTools.generateUri("/exports/price-list").toString(),
            headers: {
              "branch-id": ?BranchesTool.getCurrentBranch()?.id.toString(),
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
              "branch-id": ?BranchesTool.getCurrentBranch()?.id.toString(),
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
