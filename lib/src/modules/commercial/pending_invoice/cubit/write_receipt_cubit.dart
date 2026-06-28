import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

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
