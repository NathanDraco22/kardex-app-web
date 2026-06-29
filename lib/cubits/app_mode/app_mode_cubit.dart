import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/app_env.dart';
import 'package:kardex_app_front/src/core/app_kardex_config.dart';
import 'package:kardex_app_front/src/core/session_manager.dart';

part 'app_mode_state.dart';

class AppModeCubit extends Cubit<AppModeState> {
  AppModeCubit() : super(NormalModeState());

  Future<void> switchToPracticeMode() async {
    AppKardexConfig().setPracticeUrl(AppEnv.practiceUrl);
    clearSession();
    emit(PracticeModeState());
  }

  void switchToNormalMode() {
    AppKardexConfig().setPracticeUrl("");
    emit(NormalModeState());
  }

  Future<void> clearSession() async {
    await SessionManager().removeSession();
  }
}
