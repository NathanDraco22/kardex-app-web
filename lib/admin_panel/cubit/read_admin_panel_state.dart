part of 'read_admin_panel_cubit.dart';

sealed class ReadAdminPanelState {}

final class ReadAdminPanelInitial extends ReadAdminPanelState {}

final class ReadAdminPanelLoading extends ReadAdminPanelState {}

final class ReadAdminPanelSuccess extends ReadAdminPanelState {
  final AdminChartsResponses charts;

  ReadAdminPanelSuccess(this.charts);
}

final class ReadAdminPanelFailure extends ReadAdminPanelState {
  final String message;

  ReadAdminPanelFailure(this.message);
}
