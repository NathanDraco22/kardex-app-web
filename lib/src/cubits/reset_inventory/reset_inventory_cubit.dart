import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_business/kardex_business.dart';
import 'reset_inventory_state.dart';

class ResetInventoryCubit extends Cubit<ResetInventoryState> {
  final InventoriesRepository repository;

  ResetInventoryCubit({required this.repository})
      : super(ResetInventoryInitial());

  Future<void> resetBranchInventory({
    required String branchId,
    required String branchNameConfirm,
    String? description,
    required UserInfo createdBy,
  }) async {
    emit(ResetInventoryLoading());
    try {
      final res = await repository.resetBranchInventory(
        branchId: branchId,
        branchNameConfirm: branchNameConfirm,
        description: description,
        createdBy: createdBy,
      );
      emit(ResetInventorySuccess(res));
    } catch (e) {
      emit(ResetInventoryFailure(e.toString()));
    }
  }

  void resetState() {
    emit(ResetInventoryInitial());
  }
}
