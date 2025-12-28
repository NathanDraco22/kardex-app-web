import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/transfer/transfer_in_db.dart';
import 'package:kardex_app_front/src/domain/repositories/transfers_repository.dart';

part 'write_transfer_state.dart';

class WriteTransferCubit extends Cubit<WriteTransferState> {
  final TransfersRepository repository;

  WriteTransferCubit({required this.repository}) : super(const WriteTransferInitial());

  Future<void> createTransfer(CreateTransfer transfer) async {
    emit(const WriteTransferLoading());
    try {
      final result = await repository.createTransfer(transfer);
      emit(WriteTransferSuccess(result));
    } catch (e) {
      emit(WriteTransferFailure(e.toString()));
    }
  }
}
