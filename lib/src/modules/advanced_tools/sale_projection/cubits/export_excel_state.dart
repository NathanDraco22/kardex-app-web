part of 'export_excel_cubit.dart';

sealed class ExportExcelState {}

final class ExportExcelInitial extends ExportExcelState {}

final class ExportExcelLoading extends ExportExcelState {}

final class ExportExcelSuccess extends ExportExcelState {}

final class ExportExcelFailure extends ExportExcelState {
  final String message;

  ExportExcelFailure({required this.message});
}
