part of 'export_price_list_cubit.dart';

@immutable
sealed class ExportPriceListState {}

final class ExportPriceListInitial extends ExportPriceListState {}

final class ExportPriceListLoading extends ExportPriceListState {}

final class ExportPriceListSuccess extends ExportPriceListState {}

final class ExportPriceListFailure extends ExportPriceListState {
  final String message;
  ExportPriceListFailure({required this.message});
}
