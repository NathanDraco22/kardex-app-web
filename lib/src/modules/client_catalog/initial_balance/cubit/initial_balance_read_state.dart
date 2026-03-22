part of 'initial_balance_read_cubit.dart';

abstract class InitialBalanceReadState {}

class InitialBalanceReadInitial extends InitialBalanceReadState {}

class InitialBalanceReadLoading extends InitialBalanceReadState {}

class InitialBalanceReadSuccess extends InitialBalanceReadState {
  final List<ClientInDb> clients;

  InitialBalanceReadSuccess(this.clients);
}

class InitialBalanceReadError extends InitialBalanceReadState {
  final String message;

  InitialBalanceReadError(this.message);
}
