part of 'estimate_product_stats_cubit.dart';

sealed class EstimateProductStatsState {}

final class EstimateProductStatsInitial extends EstimateProductStatsState {}

final class EstimateProductStatsLoading extends EstimateProductStatsState {}

final class EstimateProductStatsSuccess extends EstimateProductStatsState {}

final class EstimateProductStatsFailure extends EstimateProductStatsState {
  final String message;

  EstimateProductStatsFailure(this.message);
}
