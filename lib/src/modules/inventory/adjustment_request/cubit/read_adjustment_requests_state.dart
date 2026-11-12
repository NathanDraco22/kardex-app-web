part of 'read_adjustment_requests_cubit.dart';

sealed class ReadAdjustmentRequestsState {
  const ReadAdjustmentRequestsState();
}

final class ReadAdjustmentRequestsInitial extends ReadAdjustmentRequestsState {}

final class ReadAdjustmentRequestsLoading extends ReadAdjustmentRequestsState {}

class ReadAdjustmentRequestsSuccess extends ReadAdjustmentRequestsState {
  const ReadAdjustmentRequestsSuccess({
    required this.items,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.loadMoreError,
  });

  final List<AdjustmentRequestInDb> items;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final String? loadMoreError;

  ReadAdjustmentRequestsSuccess copyWith({
    List<AdjustmentRequestInDb>? items,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    String? loadMoreError,
    bool clearLoadMoreError = false,
  }) {
    return ReadAdjustmentRequestsSuccess(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      loadMoreError: clearLoadMoreError ? null : (loadMoreError ?? this.loadMoreError),
    );
  }
}

final class ReadAdjustmentRequestsError extends ReadAdjustmentRequestsState {
  const ReadAdjustmentRequestsError(this.message);

  final String message;
}
