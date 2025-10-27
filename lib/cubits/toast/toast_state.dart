part of 'toast_cubit.dart';

sealed class ToastState {}

final class ToastInitial extends ToastState {}

final class ToastMessage extends ToastState {
  final String message;
  ToastMessage(this.message);
}
