import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_state.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

import 'shift_state.dart';

class ShiftCubit extends Cubit<ShiftState> {
  final ShiftsRepository shiftsRepository;

  StreamSubscription<AppSettingsState>? _settingsSub;
  StreamSubscription<RepoEvent<ShiftInDb>>? _repoSub;
  bool _lastUseShifts = false;

  ShiftCubit({required this.shiftsRepository}) : super(ShiftInitial()) {
    _listenAppSettings();
    _listenRepository();
  }

  bool get isFeatureEnabled =>
      getIt.isRegistered<AppSettingsCubit>() &&
      getIt<AppSettingsCubit>().useShifts;

  ShiftInDb? get currentShift =>
      state is ShiftActive ? (state as ShiftActive).shift : null;

  bool get hasOpenShift =>
      currentShift != null && currentShift!.status == ShiftStatus.open;

  bool get isOpenInCurrentBranch {
    if (!hasOpenShift || !getIt.isRegistered<AuthCubit>()) return false;
    return currentShift!.branchId == getIt<AuthCubit>().currentBranchId;
  }

  bool get isBlockedByOtherBranch {
    if (!hasOpenShift || !getIt.isRegistered<AuthCubit>()) return false;
    return currentShift!.branchId != getIt<AuthCubit>().currentBranchId;
  }

  String? get activeShiftId =>
      (isFeatureEnabled && isOpenInCurrentBranch) ? currentShift?.id : null;

  void _listenAppSettings() {
    if (!getIt.isRegistered<AppSettingsCubit>()) return;
    final settingsCubit = getIt<AppSettingsCubit>();
    _lastUseShifts = settingsCubit.useShifts;
    if (!_lastUseShifts) {
      emit(ShiftFeatureDisabled());
    }
    _settingsSub = settingsCubit.stream.listen((_) {
      final enabled = settingsCubit.useShifts;
      if (!enabled) {
        _lastUseShifts = false;
        emit(ShiftFeatureDisabled());
        return;
      }
      if (!_lastUseShifts && enabled) {
        _lastUseShifts = true;
        loadActiveShift();
      }
    });
  }

  void _listenRepository() {
    _repoSub = shiftsRepository.eventStream.listen((event) {
      if (!isFeatureEnabled) return;
      final currentUserId = _currentUserId;
      if (currentUserId == null) return;

      switch (event) {
        case RepoItemCreated<ShiftInDb>(:final item):
          if (item.openedBy.id == currentUserId &&
              item.status == ShiftStatus.open) {
            emit(ShiftActive(item));
          }
        case RepoItemUpdated<ShiftInDb>(:final item):
          if (item.openedBy.id != currentUserId) return;
          if (item.status == ShiftStatus.open) {
            emit(ShiftActive(item));
          } else if (currentShift?.id == item.id || state is ShiftActive) {
            emit(ShiftNoneOpen());
          }
        case RepoItemDeleted<ShiftInDb>():
          break;
      }
    });
  }

  String? get _currentUserId {
    if (!getIt.isRegistered<AuthCubit>()) return null;
    return getIt<AuthCubit>().user?.id;
  }

  Future<void> loadActiveShift() async {
    if (!isFeatureEnabled) {
      emit(ShiftFeatureDisabled());
      return;
    }

    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      emit(ShiftNoneOpen());
      return;
    }

    emit(ShiftLoading());
    try {
      final active = await shiftsRepository.getActiveShiftByUser(userId);
      if (isClosed) return;
      if (active != null && active.status == ShiftStatus.open) {
        emit(ShiftActive(active));
      } else {
        emit(ShiftNoneOpen());
      }
    } catch (e) {
      if (isClosed) return;
      emit(ShiftError(e.toString()));
    }
  }

  void clear() {
    if (!isFeatureEnabled) {
      emit(ShiftFeatureDisabled());
    } else {
      emit(ShiftNoneOpen());
    }
  }

  @override
  Future<void> close() async {
    await _settingsSub?.cancel();
    await _repoSub?.cancel();
    return super.close();
  }
}
