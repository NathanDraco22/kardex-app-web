import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'initial_balance_write_state.dart';

class InitialBalanceWriteCubit extends Cubit<InitialBalanceWriteState> {
  InitialBalanceWriteCubit(this.clientsRepository) : super(InitialBalanceWriteInitial());

  final ClientsRepository clientsRepository;

  Future<void> createMultipleInitialBalance(CreateMultipleInitialBalance payload) async {
    emit(InitialBalanceWriteInProgress());
    try {
      final client = await clientsRepository.createMultipleInitialBalance(payload);
      emit(InitialBalanceWriteSuccess(client));
    } catch (error) {
      emit(InitialBalanceWriteError(error.toString()));
    }
  }
}
