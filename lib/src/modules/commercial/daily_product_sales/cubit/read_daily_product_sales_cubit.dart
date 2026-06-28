import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_daily_product_sales_state.dart';

class ReadDailyProductSalesCubit extends Cubit<ReadDailyProductSalesState> {
  ReadDailyProductSalesCubit({required this.invoicesRepository, this.defaultCreatorId})
    : super(ReadDailyProductSalesInitial()) {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    startDate = todayMidnight;
    userCreatorId = defaultCreatorId;
  }

  String? defaultCreatorId;

  DateTime? startDate;
  String? userCreatorId;

  final InvoicesRepository invoicesRepository;

  Future<void> loadDailyProductSales({required String branchId, DateTime? startDate, String? userCreatorId}) async {
    emit(ReadDailyProductSalesLoading());
    if (startDate != null) {
      this.startDate = startDate;
    }
    if (userCreatorId != null && defaultCreatorId == null) {
      this.userCreatorId = userCreatorId;
    }

    try {
      final topEndDate = this.startDate?.add(const Duration(days: 1));

      final params = InvoiceQueryParams()
        ..branchId = branchId
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

  void clearFilters(String branchId) {
    startDate = DateTimeTool.getTodayMidnight();
    userCreatorId = defaultCreatorId;
    loadDailyProductSales(branchId: branchId, startDate: startDate);
  }
}
