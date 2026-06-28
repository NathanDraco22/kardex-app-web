import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_order_state.dart';

class ReadOrderCubit extends Cubit<ReadOrderState> {
  ReadOrderCubit({
    required this.ordersRepository,
  }) : super(ReadOrderInitial());

  final OrdersRepository ordersRepository;

  bool isLastPage = false;
  List<OrderInDb> _ordersCache = [];

  String? clientId;

  Future<void> loadPaginatedOrders(String branchId) async {
    emit(ReadOrderLoading());
    try {
      final response = await ordersRepository.getPaginatedOrders(
        queryParams: OrderQueryParams(
          skip: 0,
          limit: 100,
          branchId: branchId,
          clientId: clientId,
          neStatus: OrderStatus.draft,
        ),
      );

      _ordersCache = response.data;
      if (_ordersCache.length >= response.count) {
        isLastPage = true;
      } else {
        isLastPage = false;
      }
      if (isClosed) return;
      emit(ReadOrderSuccess(_ordersCache, response.count));
    } catch (error) {
      if (isClosed) return;
      emit(ReadOrderError(error.toString()));
    }
  }

  Future<void> setFilterParams({
    String? clientId,
  }) async {
    this.clientId = clientId;
    _ordersCache = [];
    isLastPage = false;
  }

  Future<void> clearFilterParams(String branchId) async {
    clientId = null;
    _ordersCache = [];
    isLastPage = false;
    loadPaginatedOrders(branchId);
  }

  Future<void> updateOrderCache(OrderInDb order) async {
    final index = _ordersCache.indexWhere((element) => element.id == order.id);
    if (index != -1) {
      _ordersCache[index] = order;
      emit(ReadOrderSuccess(_ordersCache, _ordersCache.length));
    }
  }
}
