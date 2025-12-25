part of 'read_product_stats_cubit.dart';

sealed class ReadProductStatsState {}

final class ReadProductStatsInitial extends ReadProductStatsState {}

final class ReadProductStatsLoading extends ReadProductStatsState {}

final class ReadProductStatsSuccess extends ReadProductStatsState {
  final List<ProductStatInDbWithInfo> stats;

  ReadProductStatsSuccess(this.stats);
}

final class ReadProductStatsFailure extends ReadProductStatsState {
  final String message;

  ReadProductStatsFailure(this.message);
}
