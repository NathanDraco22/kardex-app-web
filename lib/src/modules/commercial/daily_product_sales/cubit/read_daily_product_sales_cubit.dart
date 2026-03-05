import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/common/product_sale_total.dart';
import 'package:kardex_app_front/src/domain/query_params/history_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_daily_product_sales_state.dart';

class ReadDailyProductSalesCubit extends Cubit<ReadDailyProductSalesState> {
  ReadDailyProductSalesCubit({required this.invoicesRepository}) : super(ReadDailyProductSalesInitial()) {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    startDate = todayMidnight;
  }

  DateTime? startDate;
  String? userCreatorId;

  final InvoicesRepository invoicesRepository;

  Future<void> loadDailyProductSales({DateTime? startDate, String? userCreatorId}) async {
    emit(ReadDailyProductSalesLoading());
    if (startDate != null) {
      this.startDate = startDate;
    }
    if (userCreatorId != null) {
      this.userCreatorId = userCreatorId;
    }

    try {
      final topEndDate = this.startDate?.add(const Duration(days: 1));

      final params = InvoiceQueryParams()
        ..startDate = this.startDate
        ..endDate = topEndDate
        ..createdBy = this.userCreatorId
        ..limit = 10000;

      final result = await invoicesRepository.getAllProductSales(params);

      int totalAmount = 0;
      for (final item in result) {
        totalAmount += item.total;
      }

      emit(ReadDailyProductSalesSuccess(result, totalAmount));
    } catch (e) {
      emit(ReadDailyProductSalesError(e.toString()));
    }
  }

  void clearFilters() {
    startDate = DateTimeTool.getTodayMidnight();
    userCreatorId = null;
    loadDailyProductSales(startDate: startDate);
  }
}
