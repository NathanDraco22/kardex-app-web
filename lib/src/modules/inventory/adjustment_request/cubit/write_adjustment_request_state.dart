part of 'write_adjustment_request_cubit.dart';

sealed class WriteAdjustmentRequestState {
  const WriteAdjustmentRequestState();
}

final class WriteAdjustmentRequestInitial extends WriteAdjustmentRequestState {}

final class WritingAdjustmentRequest extends WriteAdjustmentRequestState {}

sealed class WriteAdjustmentRequestSuccess extends WriteAdjustmentRequestState {
  const WriteAdjustmentRequestSuccess(this.item);

  final AdjustmentRequestInDb item;
}

final class AdjustmentRequestCreated extends WriteAdjustmentRequestSuccess {
  const AdjustmentRequestCreated(super.item);
}

final class AdjustmentRequestUpdated extends WriteAdjustmentRequestSuccess {
  const AdjustmentRequestUpdated(super.item);
}

final class AdjustmentRequestApproved extends WriteAdjustmentRequestSuccess {
  const AdjustmentRequestApproved(super.item);
}

final class AdjustmentRequestCancelled extends WriteAdjustmentRequestSuccess {
  const AdjustmentRequestCancelled(super.item);
}

final class WriteAdjustmentRequestError extends WriteAdjustmentRequestState {
  const WriteAdjustmentRequestError(this.message);

  final String message;
}
