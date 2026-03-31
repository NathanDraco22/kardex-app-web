part of 'write_product_account_cubit.dart';

sealed class WriteProductAccountState {}

final class WriteProductAccountInitial extends WriteProductAccountState {}

final class WriteProductAccountInProgress extends WriteProductAccountState {}

final class WriteProductAccountSuccess extends WriteProductAccountState {
  final ProductAccountInDb account;
  WriteProductAccountSuccess(this.account);
}

final class WriteProductAccountFailure extends WriteProductAccountState {
  final String message;
  WriteProductAccountFailure(this.message);
}
