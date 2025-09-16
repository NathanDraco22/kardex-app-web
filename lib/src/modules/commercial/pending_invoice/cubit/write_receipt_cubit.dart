import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/receipt/receipt_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'write_receipt_state.dart';

class WriteReceiptCubit extends Cubit<WriteReceiptState> {
  WriteReceiptCubit({required this.receiptsRepository}) : super(WriteReceiptInitial());

  final ReceiptsRepository receiptsRepository;

  Future<void> createNewReceipt(CreateReceipt createReceipt) async {
    emit(WriteReceiptInProgress());
    try {
      final receipt = await receiptsRepository.createReceipt(createReceipt);
      emit(WriteReceiptSuccess(receipt));
      emit(WriteReceiptInitial());
    } catch (error) {
      emit(WriteReceiptError(error.toString()));
    }
  }
}
