import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/src/domain/query_params/order_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';

part 'read_proforma_state.dart';

class ReadProformaCubit extends Cubit<ReadProformaState> {
  ReadProformaCubit({
    required this.ordersRepository,
  }) : super(ReadProformaInitial());

  final OrdersRepository ordersRepository;

  bool isLastPage = false;
  List<OrderInDb> _ordersCache = [];

  String? clientId;

  Future<void> loadPaginatedOrders() async {
    emit(ReadProformaLoading());
    final currentBranch = BranchesTool.getCurrentBranchId();
    try {
      final response = await ordersRepository.getPaginatedOrders(
        queryParams: OrderQueryParams(
          skip: 0,
          limit: 100,
          branchId: currentBranch,
          clientId: clientId,
          status: OrderStatus.draft,
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
