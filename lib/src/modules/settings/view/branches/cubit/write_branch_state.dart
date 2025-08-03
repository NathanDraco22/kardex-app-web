part of 'write_branch_cubit.dart';

sealed class WriteBranchState {}

final class WriteBranchInitial extends WriteBranchState {}

final class WriteBranchInProgress extends WriteBranchState {}

final class WriteBranchSuccess extends WriteBranchState {
  final BranchInDb branch;
  WriteBranchSuccess(this.branch);
}

final class DeleteBranchSuccess extends WriteBranchState {
  final BranchInDb branch;
  DeleteBranchSuccess(this.branch);
}

final class WriteBranchError extends WriteBranchState {
  final String error;
  WriteBranchError(this.error);
}
