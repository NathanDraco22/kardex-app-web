import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_product_stock_demand_state.dart';

class ReadProductStockDemandCubit extends Cubit<ReadProductStockDemandState> {
  ReadProductStockDemandCubit({
    required this.ordersRepository,
  }) : super(ReadProductStockDemandInitial());

  final OrdersRepository ordersRepository;

  Future<void> loadProductStockDemand(String branchId) async {
    emit(ReadProductStockDemandLoading());
    try {
      final params = OrderQueryParams(
        status: OrderStatus.draft,
        branchId: branchId,
      );

      final result = await ordersRepository.productVSDemand(queryParams: params);

      emit(ReadProductStockDemandSuccess(result));
    } catch (e) {
      emit(ReadProductStockDemandError(e.toString()));
    }
  }
}
