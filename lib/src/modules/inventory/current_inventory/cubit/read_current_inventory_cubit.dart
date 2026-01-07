import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/inventory/inventory_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_current_inventory_state.dart';

class ReadCurrentInventoryCubit extends Cubit<ReadCurrentInventoryState> {
  ReadCurrentInventoryCubit({required this.inventoriesRepository}) : super(ReadCurrentInventoryInitial());

  final InventoriesRepository inventoriesRepository;

  List<InventoryInDb> _currentInventories = [];

  Future<void> loadAllInventories() async {
    emit(ReadCurrentInventoryLoading());
    try {
      final inventories = await inventoriesRepository.getAllInventories();
      if (isClosed) return;
      _currentInventories = inventories;
      emit(ReadCurrentInventorySuccess(inventories));
    } catch (error) {
      if (isClosed) return;
      emit(ReadCurrentInventoryError(error.toString()));
    }
  }

  Future<void> searchInventoryByKeyword(String keyword) async {
    try {
      if (keyword.isEmpty) {
        emit(ReadCurrentInventorySuccess(_currentInventories));
        return;
      }
      final filtered = _currentInventories
          .where(
            (inventory) => inventory.product.name.toLowerCase().contains(
              keyword.toLowerCase(),
            ),
          )
          .toList();
      emit(ReadCurrentInventorySuccess(filtered));
    } catch (error) {
      if (isClosed) return;
      emit(ReadCurrentInventorySuccess(_currentInventories));
    }
  }
}
