part of 'read_proforma_cubit.dart';

sealed class ReadProformaState {}

final class ReadProformaInitial extends ReadProformaState {}

final class ReadProformaLoading extends ReadProformaState {}

final class ReadProformaError extends ReadProformaState {
  final String message;

  ReadProformaError(this.message);
}

final class ReadProformaSuccess extends ReadProformaState {
  final List<OrderInDb> orders;
  final int count;
  final Set<String> newOrderIds;
  final Set<String> updatedOrderIds;

  ReadProformaSuccess(
    this.orders,
    this.count, {
    this.newOrderIds = const {},
    this.updatedOrderIds = const {},
  });
}
