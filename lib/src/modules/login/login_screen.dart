import 'dart:async';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/app_env.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/app_mode/app_mode_cubit.dart';
import 'package:kardex_app_front/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/src/tools/navigation_tool.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/password_title_textfield.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final authCubit = getIt<AuthCubit>();
    final appModeCubit = context.read<AppModeCubit>();
    return BlocListener(
      bloc: authCubit,
      listener: (context, state) async {
        if (state is AuthInactive) {
          context.goNamed("activation");
        }
        if (state is AuthLoading) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is! AuthLoading) {
          LoadingDialogManager.closeLoadingDialog(context);
        }

        if (state is Authenticated) {
          if (appModeCubit.state is PracticeModeState) {
            await appModeCubit.clearSession();
          }
          if (!context.mounted) return;
          final routeName = NavigationTool.getNavigationAuthenticatedDestination(
            state.servin,
            state.session.user,
          );
          context.goNamed(routeName);
        }

        if (state is AuthError) {
          DialogManager.showErrorDialog(context, state.message);
        }

        if (state is Unauthenticated) {
          context.goNamed("login");
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leading: IconButton(
            onPressed: () async {
              String? businessName;
              if (authCubit.state is Unauthenticated) {
                businessName = (authCubit.state as Unauthenticated).servin?.name;
              }

              final res = await showDialog<bool>(
                context: context,
                barrierDismissible: false,
                builder: (context) => _ExitBusinessDialog(
                  businessName: businessName ?? "este negocio",
                ),
              );

              if (res == true) {
                await authCubit.exitFromBusiness();
                if (!context.mounted) return;
                context.goNamed("activation");
              }
            },
            icon: const Icon(
              Icons.close,
              color: Colors.white70,
            ),
          ),
        ),
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  String userId = "";
  String password = "";
  String _businessName = "";

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_businessName.isEmpty) {
      _businessName = getIt<AuthCubit>().servin?.name ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final appSettings = context.watch<AppSettingsCubit>();

    return Container(
      height: screenSize.height,
      width: screenSize.width,
      decoration: const BoxDecoration(
        color: Colors.black,
        image: DecorationImage(
          image: AssetImage("assets/bg/menu_bg.png"),
          fit: BoxFit.cover,
          opacity: 0.2,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _CompanyLoginAvatar(
                          imageUrl: appSettings.companyLogoUrl,
                          businessName: _businessName,
                        ),
                        const SizedBox(height: 20),
                        if (_businessName.isNotEmpty) ...[
                          Text(
                            _businessName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              color: Colors.white.withAlpha(230),
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                            fontSize: _businessName.isEmpty ? 20 : 14,
                            fontWeight: _businessName.isEmpty
                                ? FontWeight.bold
                                : FontWeight.w500,
                            letterSpacing: 0.4,
                            color: Colors.white.withAlpha(
                              _businessName.isEmpty ? 210 : 155,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Card(
                          color: Colors.white.withAlpha(230),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TitleTextField(
                                  title: "Codigo de Usuario",
                                  onEditingComplete: () =>
                                      FocusScope.of(context).nextFocus(),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    userId = value.trim();
                                  },
                                ),
                                const SizedBox(height: 8),
                                PasswordTextField(
                                  title: "Contraseña",
                                  onEditingComplete: () {
                                    getIt<AuthCubit>().login(userId, password);
                                  },
                                  onChanged: (value) {
                                    password = value.trim();
                                  },
                                ),

                                const SizedBox(height: 16),
                                PrimaryMenuButton(
                                  onPressed: () {
                                    getIt<AuthCubit>().login(userId, password);
                                  },
                                  label: const Text("Iniciar Sesión"),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        const _ModeButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Avatar circular del negocio, al estilo de la pantalla de login de macOS.
class _CompanyLoginAvatar extends StatelessWidget {
  const _CompanyLoginAvatar({
    required this.imageUrl,
    required this.businessName,
  });

  static const double _size = 132;
  static const double _logoPadding = 16;

  final String? imageUrl;
  final String businessName;

  @override
  Widget build(BuildContext context) {
    final name = businessName.trim();
    final initial = name.isEmpty ? null : name.substring(0, 1).toUpperCase();

    final fallback = Center(
      child: initial != null
          ? Text(
              initial,
              style: const TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.w600,
                color: Color(0xFF072A3C),
              ),
            )
          : const Icon(
              Icons.storefront_rounded,
              size: 50,
              color: Color(0xFF072A3C),
            ),
    );

    return Container(
      width: _size,
      height: _size,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(_logoPadding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(90),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: CompanyLogo(
        imageUrl: imageUrl,
        fit: BoxFit.contain,
        fallback: fallback,
        placeholder: fallback,
        fadeInDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton();

  @override
  Widget build(BuildContext context) {
    if (AppEnv.practiceUrl.isEmpty) return const SizedBox.shrink();
    final appModeCubit = context.watch<AppModeCubit>();
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.cyan,
      ),
      onPressed: () async {
        if (appModeCubit.state is NormalModeState) {
          final res = await DialogManager.confirmActionDialog(
            context,
            "Deseas cambiar a Modo Practica?",
          );
          if (!res) return;
          appModeCubit.switchToPracticeMode();
        } else {
          final res = await DialogManager.confirmActionDialog(
            context,
            "Deseas cambiar a Modo Normal?",
          );

          if (!res) return;
          appModeCubit.switchToNormalMode();
        }
      },
      child: Builder(
        builder: (context) {
          final state = appModeCubit.state;
          if (state is NormalModeState) {
            return const Text("Cambiar a Modo Practica");
          }
          return const Text("Cambiar a Modo Normal");
        },
      ),
    );
  }
}

class _ExitBusinessDialog extends StatefulWidget {
  final String businessName;

  const _ExitBusinessDialog({required this.businessName});

  @override
  State<_ExitBusinessDialog> createState() => _ExitBusinessDialogState();
}

class _ExitBusinessDialogState extends State<_ExitBusinessDialog> {
  int _secondsRemaining = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Salir del Negocio"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("¿Deseas salir de ${widget.businessName}?"),
          const SizedBox(height: 16),
          if (_secondsRemaining > 0)
            Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "Espera $_secondsRemaining segundos...",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            )
          else
            const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text(
                  "Ya puedes confirmar la salida.",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: _secondsRemaining > 0
              ? null
              : () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade800,
            foregroundColor: Colors.white,
          ),
          child: const Text("Aceptar"),
        ),
      ],
    );
  }
}
