part of 'read_finance_charts_cubit.dart';

sealed class ReadFinanceChartsState {}

final class ReadFinanceChartsInitial extends ReadFinanceChartsState {}

final class ReadFinanceChartsLoading extends ReadFinanceChartsState {}

final class ReadFinanceChartsSuccess extends ReadFinanceChartsState {
  final AdminChartsResponses charts;

  ReadFinanceChartsSuccess(this.charts);
}

final class ReadFinanceChartsFailure extends ReadFinanceChartsState {
  final String message;

  ReadFinanceChartsFailure(this.message);
}
