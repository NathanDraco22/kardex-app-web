import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_order_state.dart';

class ReadOrderCubit extends Cubit<ReadOrderState> {
  ReadOrderCubit({required this.ordersRepository}) : super(ReadOrderInitial());

  final OrdersRepository ordersRepository;

  bool isLastPage = false;
  List<OrderInDb> _ordersCache = [];

  String? clientId;

  Future<void> loadPaginatedOrders() async {
    emit(ReadOrderLoading());
    try {
      final response = await ordersRepository.getPaginatedOrders(
        offset: 0,
        clientId: clientId,
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

  Future<void> getNextPage() async {
    if (isLastPage) return;
    try {
      final response = await ordersRepository.getPaginatedOrders(
        offset: _ordersCache.length,
        clientId: clientId,
      );

      _ordersCache.addAll(response.data);
      if (_ordersCache.length >= response.count) {
        isLastPage = true;
      }
      if (isClosed) return;
      emit(ReadOrderSuccess(_ordersCache, response.count));
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> setFilterParams({
    String? clientId,
    String? startDate,
    String? endDate,
  }) async {
    this.clientId = clientId;
    _ordersCache = [];
    isLastPage = false;
  }

  Future<void> clearFilterParams() async {
    clientId = null;
    _ordersCache = [];
    isLastPage = false;
    loadPaginatedOrders();
  }

  Future<void> updateOrderCache(OrderInDb order) async {
    final index = _ordersCache.indexWhere((element) => element.id == order.id);
    if (index != -1) {
      _ordersCache[index] = order;
      emit(ReadOrderSuccess(_ordersCache, _ordersCache.length));
    }
  }
}
