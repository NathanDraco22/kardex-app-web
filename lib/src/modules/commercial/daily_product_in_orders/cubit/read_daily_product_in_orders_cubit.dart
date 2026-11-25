import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_daily_product_in_orders_state.dart';

class ReadDailyProductInOrdersCubit extends Cubit<ReadDailyProductInOrdersState> {
  ReadDailyProductInOrdersCubit({required this.ordersRepository, this.defaultCreatorId})
    : super(ReadDailyProductInOrdersInitial()) {
    final todayMidnight = DateTimeTool.getTodayMidnight();
    startDate = todayMidnight;
    endDate = todayMidnight.endOfDay();
    userCreatorId = defaultCreatorId;
  }

  final String? defaultCreatorId;

  DateTime? startDate;
  DateTime? endDate;
  String? userCreatorId;
  String? clientId;

  final OrdersRepository ordersRepository;

  Future<void> loadDailyProductInOrders({
    required String branchId,
    DateTime? startDate,
    DateTime? endDate,
    String? userCreatorId,
    bool clearUserCreator = false,
    String? clientId,
    bool clearClient = false,
  }) async {
    emit(ReadDailyProductInOrdersLoading());
    if (startDate != null) {
      this.startDate = startDate;
    }
    if (endDate != null) {
      this.endDate = endDate;
    }

    if (this.startDate != null && this.endDate != null && this.startDate!.startOfDay().isAfter(this.endDate!.startOfDay())) {
      if (startDate != null && endDate == null) {
        this.endDate = this.startDate!.endOfDay();
      } else {
        this.startDate = this.endDate!.startOfDay();
      }
    }

    if (defaultCreatorId != null) {
      this.userCreatorId = defaultCreatorId;
    } else if (clearUserCreator) {
      this.userCreatorId = null;
    } else if (userCreatorId != null) {
      this.userCreatorId = userCreatorId;
    }

    if (clearClient) {
      this.clientId = null;
    } else if (clientId != null) {
      this.clientId = clientId;
    }

    try {
      final effectiveStartDate = this.startDate?.startOfDay();
      final effectiveEndDate = (this.endDate ?? this.startDate)?.endOfDay();

      final params = OrderQueryParams(
        startDate: effectiveStartDate?.millisecondsSinceEpoch,
        endDate: effectiveEndDate?.millisecondsSinceEpoch,
        neStatus: .cancelled,
        branchId: branchId,
        clientId: this.clientId,
        createdBy: this.userCreatorId,
      );

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
    final today = DateTimeTool.getTodayMidnight();
    startDate = today;
    endDate = today.endOfDay();
    clientId = null;
    userCreatorId = defaultCreatorId;
    loadDailyProductInOrders(
      branchId: branchId,
      startDate: startDate,
      endDate: endDate,
      clearClient: true,
      clearUserCreator: defaultCreatorId == null,
    );
  }
}
