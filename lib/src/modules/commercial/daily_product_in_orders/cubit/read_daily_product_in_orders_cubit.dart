import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/common/product_sale_total.dart';
import 'package:kardex_app_front/src/domain/query_params/order_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

part 'read_daily_product_in_orders_state.dart';

class ReadDailyProductInOrdersCubit extends Cubit<ReadDailyProductInOrdersState> {
  ReadDailyProductInOrdersCubit({required this.ordersRepository}) : super(ReadDailyProductInOrdersInitial()) {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    startDate = todayMidnight;
  }

  DateTime? startDate;
  String? userCreatorId;

  final OrdersRepository ordersRepository;

  Future<void> loadDailyProductInOrders({DateTime? startDate, String? userCreatorId}) async {
    emit(ReadDailyProductInOrdersLoading());
    if (startDate != null) {
      this.startDate = startDate;
    }
    if (userCreatorId != null) {
      this.userCreatorId = userCreatorId;
    }

    try {
      final topEndDate = this.startDate?.endOfDay();

      final params = OrderQueryParams(
        startDate: this.startDate?.millisecondsSinceEpoch,
        endDate: topEndDate?.millisecondsSinceEpoch,
        neStatus: .cancelled,
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

  void clearFilters() {
    startDate = DateTimeTool.getTodayMidnight();
    userCreatorId = null;
    loadDailyProductInOrders(startDate: startDate);
  }
}
