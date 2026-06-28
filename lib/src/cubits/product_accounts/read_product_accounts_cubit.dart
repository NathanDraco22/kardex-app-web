import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_product_accounts_state.dart';

class ReadProductAccountsCubit extends Cubit<ReadProductAccountsState> {
  ReadProductAccountsCubit({
    required this.productAccountsRepository,
  }) : super(ReadProductAccountsInitial());

  final ProductAccountsRepository productAccountsRepository;

  Future<void> getProductAccounts(String productId) async {
    emit(ReadProductAccountsLoading());
    try {
      final accounts = await productAccountsRepository.getProductAccountsByProduct(productId);
      emit(ReadProductAccountsSuccess(accounts));
    } catch (e) {
      emit(ReadProductAccountsFailure(e.toString()));
    }
  }
}
