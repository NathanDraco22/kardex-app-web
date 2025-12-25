import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/query_params/product_stats_query.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'estimate_product_stats_state.dart';

class EstimateProductStatsCubit extends Cubit<EstimateProductStatsState> {
  EstimateProductStatsCubit({
    required this.productStatsRepository,
  }) : super(EstimateProductStatsInitial());

  final ProductStatsRepository productStatsRepository;

  Future<void> estimate({
    required int startDate,
    required int endDate,
    required int daysAnalysis,
  }) async {
    emit(EstimateProductStatsLoading());
    try {
      final params = ProductStatQueryParams(
        startDate: startDate,
        endDate: endDate,
        daysAnalysis: daysAnalysis,
      );
      await productStatsRepository.estimate(params);
      emit(EstimateProductStatsSuccess());
    } catch (e) {
      emit(EstimateProductStatsFailure(e.toString()));
    }
  }
}
