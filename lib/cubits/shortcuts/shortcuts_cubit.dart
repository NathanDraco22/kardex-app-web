import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/shortcut/shortcut_model.dart';
import 'package:kardex_app_front/src/services/hive_service.dart';

class ShortcutsState {
  final List<Shortcut> shortcuts;
  final bool isLoading;

  const ShortcutsState({
    this.shortcuts = const [],
    this.isLoading = false,
  });

  List<String> get routes => shortcuts.map((s) => s.routeName).toList();

  ShortcutsState copyWith({
    List<Shortcut>? shortcuts,
    bool? isLoading,
  }) {
    return ShortcutsState(
      shortcuts: shortcuts ?? this.shortcuts,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ShortcutsCubit extends Cubit<ShortcutsState> with HiveService {
  static const _boxName = 'shortcuts';
  StreamSubscription? _authSubscription;
  String? _currentUserId;

  ShortcutsCubit() : super(const ShortcutsState()) {
    _initAuthListener();
  }

  void _initAuthListener() {
    final authCubit = getIt<AuthCubit>();
    _authSubscription = authCubit.stream.listen((authState) {
      if (authState is Authenticated) {
        final userId = authState.session.user.id;
        if (_currentUserId != userId) {
          loadForUser(userId);
        }
      } else {
        _currentUserId = null;
        emit(const ShortcutsState());
      }
    });

    if (authCubit.state is Authenticated) {
      final authState = authCubit.state as Authenticated;
      _currentUserId = authState.session.user.id;
      loadForUser(_currentUserId!);
    }
  }

  Future<void> loadForUser(String userId) async {
    _currentUserId = userId;
    emit(state.copyWith(isLoading: true));
    try {
      final box = await getBox(_boxName);
      final rawList = box.get(userId);
      if (rawList is List) {
        final shortcuts = rawList.map((e) => Shortcut.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        emit(ShortcutsState(shortcuts: shortcuts));
      } else {
        emit(const ShortcutsState());
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> addShortcut(String routeName) async {
    if (_currentUserId == null) return;
    if (state.routes.contains(routeName)) return;

    final shortcut = Shortcut(routeName: routeName, createdAt: DateTime.now());
    final updated = [...state.shortcuts, shortcut];

    emit(state.copyWith(shortcuts: updated));

    try {
      final box = await getBox(_boxName);
      final serialized = updated.map((s) => s.toJson()).toList();
      await box.put(_currentUserId, serialized);
    } catch (e) {
      // Silent error fallback
    }
  }

  Future<void> updateOrder(List<Shortcut> reordered) async {
    if (_currentUserId == null) return;

    emit(state.copyWith(shortcuts: reordered));

    try {
      final box = await getBox(_boxName);
      final serialized = reordered.map((s) => s.toJson()).toList();
      await box.put(_currentUserId, serialized);
    } catch (e) {
      // Silent error fallback
    }
  }

  Future<void> removeShortcut(String routeName) async {
    if (_currentUserId == null) return;

    final updated = state.shortcuts.where((s) => s.routeName != routeName).toList();

    emit(state.copyWith(shortcuts: updated));

    try {
      final box = await getBox(_boxName);
      final serialized = updated.map((s) => s.toJson()).toList();
      await box.put(_currentUserId, serialized);
    } catch (e) {
      // Silent error fallback
    }
  }

  @override
  Future<void> close() async {
    _authSubscription?.cancel();
    super.close();
  }
}
