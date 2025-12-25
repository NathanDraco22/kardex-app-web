import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product_stat/product_stat_in_db.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_product_stats_state.dart';

class ReadProductStatsCubit extends Cubit<ReadProductStatsState> {
  ReadProductStatsCubit({
    required this.productStatsRepository,
  }) : super(ReadProductStatsInitial());

  final ProductStatsRepository productStatsRepository;

  Future<void> getAllWithInfo({String? branchId}) async {
    emit(ReadProductStatsLoading());
    try {
      final stats = await productStatsRepository.getAllWithInfo(branchId: branchId);
      emit(ReadProductStatsSuccess(stats));
    } catch (e) {
      emit(ReadProductStatsFailure(e.toString()));
    }
  }
}
