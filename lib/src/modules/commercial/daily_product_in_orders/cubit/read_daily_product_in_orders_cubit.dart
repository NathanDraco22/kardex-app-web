import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_daily_product_in_orders_state.dart';

class ReadDailyProductInOrdersCubit extends Cubit<ReadDailyProductInOrdersState> {
  ReadDailyProductInOrdersCubit({required this.ordersRepository, this.defaultCreatorId})
    : super(ReadDailyProductInOrdersInitial()) {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    startDate = todayMidnight;
    userCreatorId = defaultCreatorId;
  }

  String? defaultCreatorId;

  DateTime? startDate;
  String? userCreatorId;

  final OrdersRepository ordersRepository;

  Future<void> loadDailyProductInOrders({required String branchId, DateTime? startDate, String? userCreatorId}) async {
    emit(ReadDailyProductInOrdersLoading());
    if (startDate != null) {
      this.startDate = startDate;
    }
    if (userCreatorId != null && defaultCreatorId == null) {
      this.userCreatorId = userCreatorId;
    }

    try {
      final topEndDate = this.startDate?.endOfDay();

      final params = OrderQueryParams(
        startDate: this.startDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        neStatus: .cancelled,
        branchId: branchId,
      )..createdBy = this.userCreatorId;

      final result = await ordersRepository.getProductsInOrders(queryParams: params);

      int totalAmount = 0;
      for (final item in result) {
        totalAmount += item.total;
      }

      emit(ReadDailyProductInOrdersSuccess(result, totalAmount));
    } catch (e) {
      emit(ReadDailyProductInOrdersError(e.toString()));
    }
  }

  void clearFilters(String branchId) {
    startDate = DateTimeTool.getTodayMidnight();
    userCreatorId = defaultCreatorId;
    loadDailyProductInOrders(branchId: branchId, startDate: startDate);
  }
}
