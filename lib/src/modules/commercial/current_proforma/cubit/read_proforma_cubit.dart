import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/src/domain/query_params/order_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_proforma_state.dart';

class ReadProformaCubit extends Cubit<ReadProformaState> {
  ReadProformaCubit({
    required this.ordersRepository,
  }) : super(ReadProformaInitial());

  final OrdersRepository ordersRepository;

  bool isLastPage = false;
  List<OrderInDb> _ordersCache = [];

  String? clientId;
  String? createdBy;

  Future<void> loadPaginatedOrders(String branchId) async {
    emit(ReadProformaLoading());
    try {
      final response = await ordersRepository.getPaginatedOrders(
        queryParams: OrderQueryParams(
          skip: 0,
          limit: 1000,
          branchId: branchId,
          clientId: clientId,
          status: OrderStatus.draft,
          createdBy: createdBy,
        ),
      );

      _ordersCache = response.data;
      if (_ordersCache.length >= response.count) {
        isLastPage = true;
      } else {
        isLastPage = false;
      }
      if (isClosed) return;
      emit(ReadProformaSuccess(_ordersCache, response.count));
    } catch (error) {
      if (isClosed) return;
      emit(ReadProformaError(error.toString()));
    }
  }

  Future<void> setFilterParams({
    String? clientId,
    String? createdBy,
  }) async {
    this.clientId = clientId;
    this.createdBy = createdBy;
    _ordersCache = [];
    isLastPage = false;
  }

  Future<void> clearFilterParams() async {
    clientId = null;
    createdBy = null;
    _ordersCache = [];
    isLastPage = false;
  }

  Future<void> updateOrderCache(OrderInDb order) async {
    final index = _ordersCache.indexWhere((element) => element.id == order.id);
    if (index != -1) {
      _ordersCache[index] = order;
      emit(ReadProformaSuccess(_ordersCache, _ordersCache.length));
    }
  }

  Future<void> deleteOrderDraft(String orderId) async {
    final index = _ordersCache.indexWhere((element) => element.id == orderId);
    if (index != -1) {
      _ordersCache.removeAt(index);
      emit(ReadProformaSuccess(_ordersCache, _ordersCache.length));
    }
  }
}
