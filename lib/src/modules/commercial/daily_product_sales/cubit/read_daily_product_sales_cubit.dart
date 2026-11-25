import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_daily_product_sales_state.dart';

class ReadDailyProductSalesCubit extends Cubit<ReadDailyProductSalesState> {
  ReadDailyProductSalesCubit({required this.invoicesRepository, this.defaultCreatorId})
    : super(ReadDailyProductSalesInitial()) {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    startDate = todayMidnight;
    endDate = todayMidnight;
    userCreatorId = defaultCreatorId;
  }

  String? defaultCreatorId;

  DateTime? startDate;
  DateTime? endDate;
  String? userCreatorId;
  String? clientId;

  final InvoicesRepository invoicesRepository;

  Future<void> loadDailyProductSales({
    required String branchId,
    DateTime? startDate,
    DateTime? endDate,
    String? userCreatorId,
    String? clientId,
    bool clearUserCreator = false,
    bool clearClient = false,
  }) async {
    emit(ReadDailyProductSalesLoading());
    if (startDate != null) {
      this.startDate = startDate;
    }
    if (endDate != null) {
      this.endDate = endDate;
    }
    if (defaultCreatorId == null) {
      if (clearUserCreator) {
        this.userCreatorId = null;
      } else if (userCreatorId != null) {
        this.userCreatorId = userCreatorId;
      }
    } else {
      this.userCreatorId = defaultCreatorId;
    }

    if (clearClient) {
      this.clientId = null;
    } else if (clientId != null) {
      this.clientId = clientId;
    }

    try {
      final topEndDate = this.endDate?.add(const Duration(days: 1));
      final effectiveUserCreatorId = defaultCreatorId ?? this.userCreatorId;

      final params = InvoiceQueryParams()
        ..branchId = branchId
        ..clientId = this.clientId
        ..startDate = this.startDate
        ..endDate = topEndDate
        ..createdBy = effectiveUserCreatorId
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
    final todayMidnight = DateTimeTool.getTodayMidnight();
    startDate = todayMidnight;
    endDate = todayMidnight;
    userCreatorId = defaultCreatorId;
    clientId = null;
    loadDailyProductSales(
      branchId: branchId,
      startDate: startDate,
      endDate: endDate,
      clearUserCreator: defaultCreatorId == null,
      clearClient: true,
    );
  }
}
