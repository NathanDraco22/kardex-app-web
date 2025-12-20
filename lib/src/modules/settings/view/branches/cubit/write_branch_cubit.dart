import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/tools/image_tools.dart';

part 'write_branch_state.dart';

class WriteBranchCubit extends Cubit<WriteBranchState> {
  WriteBranchCubit(this.branchesRepository) : super(WriteBranchInitial());

  final BranchesRepository branchesRepository;

  Future<void> createNewBranch(CreateBranch createBranch, XFile? image) async {
    emit(WriteBranchInProgress());
    try {
      if (image != null) {
        final base64Image = await xFileToBase64(image);
        createBranch.image = base64ToBytes(base64Image);
      }

      final branch = await branchesRepository.createBranch(createBranch);
      emit(WriteBranchSuccess(branch));
      emit(WriteBranchInitial());
    } catch (error) {
      emit(WriteBranchError(error.toString()));
    }
  }

  Future<void> updateBranch(String branchId, UpdateBranch updateBranch, XFile? image) async {
    emit(WriteBranchInProgress());
    try {
      if (image != null) {
        updateBranch.image = await xFileToBase64(image);
      }

      final branch = await branchesRepository.updateBranchById(branchId, updateBranch);
      emit(WriteBranchSuccess(branch!));
      emit(WriteBranchInitial());
    } catch (error) {
      emit(WriteBranchError(error.toString()));
    }
  }

  Future<void> deleteBranch(String branchId) async {
    emit(WriteBranchInProgress());
    try {
      final branch = await branchesRepository.deleteBranchById(branchId);
      emit(DeleteBranchSuccess(branch!));
      emit(WriteBranchInitial());
    } catch (error) {
      emit(WriteBranchError(error.toString()));
    }
  }
}
