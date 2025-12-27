import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product_stat/product_stat_in_db.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_sale_projection_state.dart';

class ReadSaleProjectionCubit extends Cubit<ReadSaleProjectionState> {
  ReadSaleProjectionCubit({
    required this.productStatsRepository,
  }) : super(ReadSaleProjectionInitial());

  final ProductStatsRepository productStatsRepository;

  Future<void> getAllWithAccount({String? branchId}) async {
    emit(ReadSaleProjectionLoading());
    try {
      final stats = await productStatsRepository.getAllWithAccount(branchId: branchId);
      emit(ReadSaleProjectionSuccess(stats));
    } catch (e) {
      emit(ReadSaleProjectionFailure(e.toString()));
    }
  }
}
