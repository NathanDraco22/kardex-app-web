import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

part 'accounts_payable_state.dart';

class AccountsPayableCubit extends Cubit<AccountsPayableState> {
  AccountsPayableCubit(
    this.expensesRepository, {
    String? branchId,
  })  : _injectedBranchId = branchId,
        super(AccountsPayableInitial());

  final ExpensesRepository expensesRepository;
  final String? _injectedBranchId;
  String? _lastBranchId;

  String get _effectiveBranchId {
    if (_injectedBranchId != null && _injectedBranchId.isNotEmpty) {
      return _injectedBranchId;
    }
    if (getIt.isRegistered<AuthCubit>()) {
      return getIt<AuthCubit>().currentBranchId;
    }
    return '';
  }

  int _localTodayCutoffMs() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  }

  Future<void> load({String? branchId}) async {
    _lastBranchId = branchId ?? _effectiveBranchId;
    emit(AccountsPayableLoading());
    try {
      final summary = await expensesRepository.getAccountsPayableSummary(
        branchId: _lastBranchId?.isEmpty == true ? null : _lastBranchId,
        overdueCutoffMs: _localTodayCutoffMs(),
      );
      if (isClosed) return;
      emit(AccountsPayableLoaded(summary: summary));
    } catch (error) {
      if (isClosed) return;
      emit(AccountsPayableError(error.toString()));
    }
  }

  Future<void> refresh() async {
    final current = state;
    final activeBranch = _effectiveBranchId;
    if (current is! AccountsPayableLoaded) {
      await load(branchId: activeBranch);
      return;
    }

    _lastBranchId = activeBranch;
    emit(current.copyWith(isRefreshing: true, clearRefreshError: true));
    try {
      final summary = await expensesRepository.getAccountsPayableSummary(
        branchId: activeBranch.isEmpty ? null : activeBranch,
        overdueCutoffMs: _localTodayCutoffMs(),
      );
      if (isClosed) return;
      emit(AccountsPayableLoaded(summary: summary));
    } catch (error) {
      if (isClosed) return;
      emit(
        current.copyWith(
          isRefreshing: false,
          refreshError: error.toString(),
        ),
      );
    }
  }
}
