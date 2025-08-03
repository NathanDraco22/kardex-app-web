part of 'read_branch_cubit.dart';

sealed class ReadBranchState {}

final class ReadBranchInitial extends ReadBranchState {}

final class ReadBranchLoading extends ReadBranchState {}

class ReadBranchSuccess extends ReadBranchState {
  final List<BranchInDb> branches;
  ReadBranchSuccess(this.branches);
}

final class BranchReadSearching extends ReadBranchSuccess {
  BranchReadSearching(super.branches);
}

class HighlightedBranch extends ReadBranchSuccess {
  List<BranchInDb> newBranches;
  List<BranchInDb> updatedBranches;
  HighlightedBranch(
    super.branches, {
    this.newBranches = const [],
    this.updatedBranches = const [],
  });
}

final class BranchInserted extends ReadBranchSuccess {
  int inserted;
  BranchInserted(this.inserted, super.branches);
}

final class BranchUpdated extends ReadBranchSuccess {
  List<BranchInDb> updated;
  BranchUpdated(this.updated, super.branches);
}

final class BranchReadError extends ReadBranchState {
  final String message;
  BranchReadError(this.message);
}
