import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/supplier/supplier_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'supplier_read_state.dart';

class ReadSupplierCubit extends Cubit<ReadSupplierState> {
  ReadSupplierCubit(this.suppliersRepository) : super(ReadSupplierInitial());

  final SuppliersRepository suppliersRepository;

  Future<void> loadAllSuppliers() async {
    emit(ReadSupplierLoading());
    try {
      final suppliers = await suppliersRepository.getAllSuppliers();
      if (isClosed) return;
      emit(ReadSupplierSuccess(suppliers));
    } catch (error) {
      if (isClosed) return;
      emit(SupplierReadError(error.toString()));
    }
  }

  Future<void> searchSupplierByKeyword(String keyword) async {
    final currentState = state as ReadSupplierSuccess;

    if (keyword.isEmpty) {
      if (isClosed) return;

      emit(ReadSupplierSuccess(suppliersRepository.suppliers));
      return;
    }

    emit(
      ReadSupplierSearching(
        currentState.suppliers,
      ),
    );
    try {
      final suppliers = await suppliersRepository.searchSupplierByKeyword(keyword);
      if (isClosed) return;

      emit(ReadSupplierSuccess(suppliers));
    } catch (error) {
      if (isClosed) return;

      emit(SupplierReadError(error.toString()));
    }
  }

  Future<void> putSupplierFirst(SupplierInDb supplier) async {
    final currentState = state as ReadSupplierSuccess;
    final freshSupplierList = suppliersRepository.suppliers;
    if (currentState is HighlightedSupplier) {
      emit(
        HighlightedSupplier(
          freshSupplierList,
          newSuppliers: [supplier, ...currentState.newSuppliers],
          updatedSuppliers: currentState.updatedSuppliers,
        ),
      );
      return;
    }
    emit(
      HighlightedSupplier(
        freshSupplierList,
        newSuppliers: [supplier],
      ),
    );
  }

  Future<void> markSupplierUpdated(SupplierInDb supplier) async {
    final currentState = state as ReadSupplierSuccess;
    final freshSupplierList = suppliersRepository.suppliers;

    if (currentState is HighlightedSupplier) {
      emit(
        HighlightedSupplier(
          freshSupplierList,
          newSuppliers: currentState.newSuppliers,
          updatedSuppliers: [supplier, ...currentState.updatedSuppliers],
        ),
      );
      return;
    }
    emit(
      HighlightedSupplier(
        freshSupplierList,
        updatedSuppliers: [supplier],
      ),
    );
  }

  Future<void> refreshSupplier() async {
    final currentState = state as ReadSupplierSuccess;
    final freshSupplierList = suppliersRepository.suppliers;
    if (currentState is HighlightedSupplier) {
      emit(
        HighlightedSupplier(
          freshSupplierList,
          newSuppliers: currentState.newSuppliers,
          updatedSuppliers: currentState.updatedSuppliers,
        ),
      );
      return;
    }
    emit(
      HighlightedSupplier(
        freshSupplierList,
      ),
    );
  }
}
