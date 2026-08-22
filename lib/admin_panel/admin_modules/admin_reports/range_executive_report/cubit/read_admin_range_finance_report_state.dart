part of 'read_admin_range_finance_report_cubit.dart';

sealed class ReadAdminRangeFinanceReportState {}

final class ReadAdminRangeFinanceReportInitial extends ReadAdminRangeFinanceReportState {}

final class ReadAdminRangeFinanceReportLoading extends ReadAdminRangeFinanceReportState {}

final class ReadAdminRangeFinanceReportSuccess extends ReadAdminRangeFinanceReportState {
  final ExecutiveSummaryInDb summary;

  ReadAdminRangeFinanceReportSuccess(this.summary);
}

final class ReadAdminRangeFinanceReportError extends ReadAdminRangeFinanceReportState {
  final String message;

  ReadAdminRangeFinanceReportError(this.message);
}
