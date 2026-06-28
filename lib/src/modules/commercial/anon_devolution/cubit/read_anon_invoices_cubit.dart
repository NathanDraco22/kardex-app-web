import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_anon_invoices_state.dart';

class ReadAnonInvoicesCubit extends Cubit<ReadAnonInvoicesState> {
  ReadAnonInvoicesCubit(this.invoicesRepository) : super(ReadAnonInvoicesInitial());

  final InvoicesRepository invoicesRepository;

  Future<void> getAnonInvoicesWithDevolutions(String docNumber) async {
    emit(ReadAnonInvoicesInProgress());
    try {
      final result = await invoicesRepository.getAnonInvoiceDevolutionByDocNumber(docNumber);
      emit(ReadAnonInvoicesSuccess(result.invoice, result.devolutions));
    } catch (error) {
      emit(ReadAnonInvoicesError(error.toString()));
    }
  }
}
