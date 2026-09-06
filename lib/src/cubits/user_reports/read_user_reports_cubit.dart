import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_business/kardex_business.dart';

part 'read_user_reports_state.dart';

class ReadUserReportsCubit extends Cubit<ReadUserReportsState> {
  ReadUserReportsCubit({
    required this.reportsRepository,
    UserInDb? initialUser,
  }) : super(ReadUserReportsInitial()) {
    startDate = DateTimeTool.getTodayMidnight();
    endDate = startDate;
    selectedUser = initialUser;
  }

  DateTime? startDate;
  DateTime? endDate;
  UserInDb? selectedUser;

  TotalsQueryParams params = TotalsQueryParams();

  final ReportsRepository reportsRepository;

  Future<void> loadReports(String branchId) async {
    emit(ReadUserReportsLoading());
    try {
      final topEndDate = endDate?.add(const Duration(days: 1));

      params = TotalsQueryParams()
        ..branchId = branchId
        ..startDate = startDate
        ..endDate = topEndDate
        ..userId = selectedUser?.id;

      final result = await reportsRepository.getTotalResultsByDateRange(params);

      emit(ReadUserReportsSuccess(result));
    } catch (e) {
      emit(ReadUserReportsError(e.toString()));
    }
  }

  void setUser(UserInDb? user, String branchId) {
    final (isSeller, sellerUser) = RoleTools.isSeller();
    if (isSeller) {
      selectedUser = sellerUser;
      loadReports(branchId);
      return;
    }
    selectedUser = user;
    loadReports(branchId);
  }

  void clearFilters(String branchId, {UserInDb? defaultUser}) {
    final (isSeller, sellerUser) = RoleTools.isSeller();
    startDate = DateTimeTool.getTodayMidnight();
    endDate = startDate;
    selectedUser = isSeller ? sellerUser : defaultUser;
    loadReports(branchId);
  }
}
