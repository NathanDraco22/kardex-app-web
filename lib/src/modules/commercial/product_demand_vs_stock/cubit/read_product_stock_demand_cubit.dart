import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/models/order/order_model.dart';
import 'package:kardex_app_front/src/domain/query_params/order_query_params.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';

part 'read_product_stock_demand_state.dart';

class ReadProductStockDemandCubit extends Cubit<ReadProductStockDemandState> {
  ReadProductStockDemandCubit({
    required this.ordersRepository,
  }) : super(ReadProductStockDemandInitial());

  final OrdersRepository ordersRepository;

  Future<void> loadProductStockDemand() async {
    emit(ReadProductStockDemandLoading());
    try {
      final params = OrderQueryParams(
        status: OrderStatus.draft,
        branchId: BranchesTool.getCurrentBranchId(),
      );

      final result = await ordersRepository.productVSDemand(queryParams: params);

      emit(ReadProductStockDemandSuccess(result));
    } catch (e) {
      emit(ReadProductStockDemandError(e.toString()));
    }
  }
}
