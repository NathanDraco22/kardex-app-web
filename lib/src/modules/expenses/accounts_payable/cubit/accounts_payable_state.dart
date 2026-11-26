part of 'accounts_payable_cubit.dart';

sealed class AccountsPayableState {}

final class AccountsPayableInitial extends AccountsPayableState {}

final class AccountsPayableLoading extends AccountsPayableState {}

final class AccountsPayableLoaded extends AccountsPayableState {
  AccountsPayableLoaded({
    required this.summary,
    this.isRefreshing = false,
    this.refreshError,
  });

  final AccountsPayableSummary summary;
  final bool isRefreshing;
  final String? refreshError;

  AccountsPayableLoaded copyWith({
    AccountsPayableSummary? summary,
    bool? isRefreshing,
    String? refreshError,
    bool clearRefreshError = false,
  }) {
    return AccountsPayableLoaded(
      summary: summary ?? this.summary,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      refreshError: clearRefreshError ? null : (refreshError ?? this.refreshError),
    );
  }
}

final class AccountsPayableError extends AccountsPayableState {
  AccountsPayableError(this.message);
  final String message;
}
