import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/supplier/supplier_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'supplier_write_state.dart';

class WriteSupplierCubit extends Cubit<WriteSupplierState> {
  WriteSupplierCubit(this.suppliersRepository) : super(WriteSupplierInitial());

  final SuppliersRepository suppliersRepository;

  Future<void> createNewSupplier(CreateSupplier createSupplier) async {
    emit(SupplierWriteInProgress());
    try {
      final supplier = await suppliersRepository.createSupplier(createSupplier);
      emit(WriteSupplierSuccess(supplier));
      emit(WriteSupplierInitial());
    } catch (error) {
      emit(WriteSupplierError(error.toString()));
    }
  }

  Future<void> updateSupplier(String supplierId, UpdateSupplier updateSupplier) async {
    emit(SupplierWriteInProgress());
    try {
      final supplier = await suppliersRepository.updateSupplierById(supplierId, updateSupplier);
      emit(WriteSupplierSuccess(supplier!));
      emit(WriteSupplierInitial());
    } catch (error) {
      emit(WriteSupplierError(error.toString()));
    }
  }

  Future<void> deleteSupplier(String supplierId) async {
    emit(SupplierWriteInProgress());
    try {
      final supplier = await suppliersRepository.deleteSupplierById(supplierId);
      emit(DeleteSupplierSuccess(supplier!));
      emit(WriteSupplierInitial());
    } catch (error) {
      emit(WriteSupplierError(error.toString()));
    }
  }
}
