import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/domain/models/common/change_password.dart';
import 'package:kardex_app_front/src/domain/repositories/auth_repository.dart';
import 'package:kardex_app_front/src/modules/change_password/cubit/change_password_cubit.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/password_title_textfield.dart';

Future<void> showChangePassword(BuildContext context) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const ChangePasswordScreen(),
    ),
  );
}

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepo = context.read<AuthRepository>();
    return BlocProvider(
      create: (context) => ChangePasswordCubit(authRepo),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ChangePasswordCubit>();
    return BlocListener(
      bloc: cubit,
      listener: (context, state) async {
        if (state is ChangePasswordInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is ChangePasswordError) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showErrorDialog(context, state.message);
        }

        if (state is ChangePasswordSuccess) {
          if (!context.mounted) return;
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showInfoDialog(context, "Contraseña cambiada con éxito");
          if (!context.mounted) return;
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text("Cambiar Contraseña")),
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
  String newPassword = "";
  String oldPassword = "";

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final state = context.read<AuthCubit>().state;

    if (state is! Authenticated) {
      context.goNamed("login");
    }

    state as Authenticated;

    return Form(
      key: formKey,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16,
                  children: [
                    PasswordTextField(
                      title: "Contraseña Actual",
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Campo requerido";
                        return null;
                      },
                      onChanged: (value) {
                        oldPassword = value;
                      },
                    ),
                    PasswordTextField(
                      title: "Nueva Contraseña",
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Campo requerido";
                        return null;
                      },
                      onChanged: (value) {
                        newPassword = value;
                      },
                    ),
                    PasswordTextField(
                      title: "Confirmar Contraseña",
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Campo requerido";
                        if (value != newPassword) {
                          return "Las contraseñas no coinciden";
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 8),

                    ElevatedButton(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;
                        context.read<ChangePasswordCubit>().changePassword(
                          ChangePasswordBody(
                            userId: state.session.user.id,
                            oldPassword: oldPassword,
                            newPassword: newPassword,
                          ),
                        );
                      },
                      child: const Text("Cambiar Contraseña"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
