import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';

part 'config_app_state.dart';

class ConfigAppCubit extends Cubit<ConfigAppState> {
  ConfigAppCubit() : super(ConfigAppState());
}
