import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

part 'export_excel_state.dart';

class ExportExcelCubit extends Cubit<ExportExcelState> {
  ExportExcelCubit({required this.productStatsRepository}) : super(ExportExcelInitial());

  final ProductStatsRepository productStatsRepository;

  Future<void> exportExcel(int projectionDays) async {
    emit(ExportExcelLoading());
    try {
      await productStatsRepository.generateExcel(projectionDays);
      await Future.delayed(const Duration(seconds: 2));
      if (kIsWeb) {
        await FileSaver.instance.saveFile(
          name: "proyeccion_ventas",
          fileExtension: "xlsx",
          mimeType: MimeType.microsoftExcel,
          link: LinkDetails(
            link: HttpTools.generateUri("/product-stats/projection/file").toString(),
            headers: HttpTools.generateAuthHeaders(),
          ),
        );
      } else {
        await FileSaver.instance.saveAs(
          name: "proyeccion_ventas",
          fileExtension: "xlsx",
          mimeType: MimeType.microsoftExcel,
          link: LinkDetails(
            link: HttpTools.generateUri("/product-stats/projection/file").toString(),
            headers: HttpTools.generateAuthHeaders(),
          ),
        );
      }

      emit(ExportExcelSuccess());
    } catch (e) {
      emit(ExportExcelFailure(message: e.toString()));
    }
  }
}
