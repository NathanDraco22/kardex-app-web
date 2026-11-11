part of 'read_adjustment_request_detail_cubit.dart';

sealed class ReadAdjustmentRequestDetailState {
  const ReadAdjustmentRequestDetailState();
}

final class ReadAdjustmentRequestDetailInitial extends ReadAdjustmentRequestDetailState {}

final class ReadAdjustmentRequestDetailLoading extends ReadAdjustmentRequestDetailState {}

final class ReadAdjustmentRequestDetailSuccess extends ReadAdjustmentRequestDetailState {
  const ReadAdjustmentRequestDetailSuccess(this.request);

  final AdjustmentRequestInDb request;
}

final class ReadAdjustmentRequestDetailError extends ReadAdjustmentRequestDetailState {
  const ReadAdjustmentRequestDetailError(this.message);

  final String message;
}
