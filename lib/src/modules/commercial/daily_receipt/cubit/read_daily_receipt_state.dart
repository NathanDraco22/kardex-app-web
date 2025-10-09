part of 'read_daily_receipt_cubit.dart';

sealed class ReadDailyReceiptsState {}

final class ReadDailyReceiptsInitial extends ReadDailyReceiptsState {}

final class ReadDailyReceiptsLoading extends ReadDailyReceiptsState {}

class ReadDailyReceiptsSuccess extends ReadDailyReceiptsState {
  final List<ReceiptInDb> receipts;
  final int totalCount;
  final ReceiptTotal totals;
  ReadDailyReceiptsSuccess(this.receipts, this.totalCount, this.totals);
}

// Estado para mostrar carga al paginar, sin perder los datos actuales
class ReadSearchingReceipt extends ReadDailyReceiptsSuccess {
  ReadSearchingReceipt(super.receipts, super.totalCount, super.totals);
}

final class ReadDailyReceiptsError extends ReadDailyReceiptsState {
  final String message;
  ReadDailyReceiptsError(this.message);
}
