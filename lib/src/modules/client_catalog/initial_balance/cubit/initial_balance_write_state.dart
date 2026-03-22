part of 'initial_balance_write_cubit.dart';

abstract class InitialBalanceWriteState {}

class InitialBalanceWriteInitial extends InitialBalanceWriteState {}

class InitialBalanceWriteInProgress extends InitialBalanceWriteState {}

class InitialBalanceWriteSuccess extends InitialBalanceWriteState {
  final ClientInDb client;

  InitialBalanceWriteSuccess(this.client);
}

class InitialBalanceWriteError extends InitialBalanceWriteState {
  final String message;

  InitialBalanceWriteError(this.message);
}
