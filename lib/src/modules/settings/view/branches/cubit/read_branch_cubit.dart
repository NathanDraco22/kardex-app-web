import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';

part 'read_branch_state.dart';

class ReadBranchCubit extends Cubit<ReadBranchState> {
  ReadBranchCubit(this.branchesRepository) : super(ReadBranchInitial());

  final BranchesRepository branchesRepository;

  Future<void> loadAllBranches() async {
    emit(ReadBranchLoading());
    try {
      final branches = await branchesRepository.getAllBranches();
      emit(ReadBranchSuccess(branches));
    } catch (error) {
      emit(BranchReadError(error.toString()));
    }
  }

  Future<void> searchBranchByKeyword(String keyword) async {
    final currentState = state as ReadBranchSuccess;

    if (keyword.isEmpty) {
      emit(ReadBranchSuccess(branchesRepository.branches));
      return;
    }

    emit(BranchReadSearching(currentState.branches));
    try {
      final branches = await branchesRepository.searchBranchByKeyword(keyword);
      emit(ReadBranchSuccess(branches));
    } catch (error) {
      emit(BranchReadError(error.toString()));
    }
  }

  Future<void> putBranchFirst(BranchInDb branch) async {
    final currentState = state as ReadBranchSuccess;
    final freshList = branchesRepository.branches;
    if (currentState is HighlightedBranch) {
      emit(
        HighlightedBranch(
          freshList,
          newBranches: [branch, ...currentState.newBranches],
          updatedBranches: currentState.updatedBranches,
        ),
      );
      return;
    }
    emit(
      HighlightedBranch(
        freshList,
        newBranches: [branch],
      ),
    );
  }

  Future<void> markBranchUpdated(BranchInDb branch) async {
    final currentState = state as ReadBranchSuccess;
    final freshList = branchesRepository.branches;

    if (currentState is HighlightedBranch) {
      emit(
        HighlightedBranch(
          freshList,
          newBranches: currentState.newBranches,
          updatedBranches: [branch, ...currentState.updatedBranches],
        ),
      );
      return;
    }
    emit(
      HighlightedBranch(
        freshList,
        updatedBranches: [branch],
      ),
    );
  }

  Future<void> refreshBranch() async {
    final currentState = state as ReadBranchSuccess;
    final freshList = branchesRepository.branches;
    if (currentState is HighlightedBranch) {
      emit(
        HighlightedBranch(
          freshList,
          newBranches: currentState.newBranches,
          updatedBranches: currentState.updatedBranches,
        ),
      );
      return;
    }
    emit(
      HighlightedBranch(
        freshList,
      ),
    );
  }
}
