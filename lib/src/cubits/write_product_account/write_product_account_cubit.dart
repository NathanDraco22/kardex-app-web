import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/product_account/product_account.dart';
import 'package:kardex_app_front/src/domain/repositories/product_accounts_repository.dart';

part 'write_product_account_state.dart';

class WriteProductAccountCubit extends Cubit<WriteProductAccountState> {
  final ProductAccountsRepository productAccountsRepository;

  WriteProductAccountCubit({
    required this.productAccountsRepository,
  }) : super(WriteProductAccountInitial());

  Future<void> addProductAccount(String productId, String branchId, {required int currentStock, required int averageCost}) async {
    try {
      emit(WriteProductAccountInProgress());
      final account = await productAccountsRepository.addProductAccount(
        productId,
        branchId,
        currentStock: currentStock,
        averageCost: averageCost,
      );
      emit(WriteProductAccountSuccess(account));
    } catch (e) {
      emit(WriteProductAccountFailure(e.toString()));
    }
  }

  Future<void> substractProductAccount(String productId, String branchId, {required int currentStock}) async {
    try {
      emit(WriteProductAccountInProgress());
      final account = await productAccountsRepository.substractProductAccount(
        productId,
        branchId,
        currentStock: currentStock,
      );
      emit(WriteProductAccountSuccess(account));
    } catch (e) {
      emit(WriteProductAccountFailure(e.toString()));
    }
  }
}
