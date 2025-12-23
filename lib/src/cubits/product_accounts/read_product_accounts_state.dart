part of 'read_product_accounts_cubit.dart';

sealed class ReadProductAccountsState {}

final class ReadProductAccountsInitial extends ReadProductAccountsState {}

final class ReadProductAccountsLoading extends ReadProductAccountsState {}

final class ReadProductAccountsSuccess extends ReadProductAccountsState {
  final List<ProductAccountInDb> accounts;

  ReadProductAccountsSuccess(this.accounts);
}

final class ReadProductAccountsFailure extends ReadProductAccountsState {
  final String message;

  ReadProductAccountsFailure(this.message);
}
