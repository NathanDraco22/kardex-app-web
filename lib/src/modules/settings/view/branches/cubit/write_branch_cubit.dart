import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/uploaders/image_uploader.dart';

part 'write_branch_state.dart';

class WriteBranchCubit extends Cubit<WriteBranchState> {
  WriteBranchCubit(this.branchesRepository) : super(WriteBranchInitial());

  final BranchesRepository branchesRepository;

  Future<void> createNewBranch(CreateBranch createBranch, XFile? image) async {
    emit(WriteBranchInProgress());
    try {
      if (image != null) {
        final bytes = await image.readAsBytes();
        final imageUrl = await ImageUploader.uploadImage(
          bytes: bytes,
          fileName: "branch_${DateTime.now().millisecondsSinceEpoch}.jpg",
        );
        createBranch.imageUrl = imageUrl;
        createBranch.image = bytes;
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
        final bytes = await image.readAsBytes();
        final imageUrl = await ImageUploader.uploadImage(
          bytes: bytes,
          fileName: "branch_${branchId}_${DateTime.now().millisecondsSinceEpoch}.jpg",
        );
        updateBranch.imageUrl = imageUrl;
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
