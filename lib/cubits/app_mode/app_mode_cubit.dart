import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/core/session_manager.dart';
import 'package:kardex_app_front/src/tools/http_tool.dart';

part 'app_mode_state.dart';

class AppModeCubit extends Cubit<AppModeState> {
  AppModeCubit() : super(NormalModeState());

  Future<void> switchToPracticeMode() async {
    HttpTools.practiceUrl = "https://kardex-server-production.up.railway.app";
    clearSession();
    emit(PracticeModeState());
  }

  void switchToNormalMode() {
    HttpTools.practiceUrl = "";
    emit(NormalModeState());
  }

  Future<void> clearSession() async {
    await SessionManager().removeSession();
  }
}
