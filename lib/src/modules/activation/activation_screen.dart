import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/activation/cubit/activation_cubit.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/password_title_textfield.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

class ActivationScreen extends StatelessWidget {
  const ActivationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final servinRepo = context.read<ServinRepository>();
    return BlocProvider(
      create: (context) => ActivationCubit(servinRepo),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivationCubit, ActivationState>(
      listener: (context, state) async {
        if (state is ActivationLoading) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is ActivationError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.message);
        }

        if (state is ActivationSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          await DialogManager.showInfoDialog(
            context,
            "Bienvenido a: \n ${state.servin.name}",
          );
          if (!context.mounted) return;
          context.goNamed("login");
        }
      },
      child: const Scaffold(
        body: _Body(),
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
  String buisnessNickname = "";
  String apiKey = "";

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Bienvenido",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withAlpha(210),
                ),
              ),

              const SizedBox(height: 16),
              Card(
                color: Colors.white.withAlpha(210),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TitleTextField(
                        title: "Alias de Negocio",
                        onEditingComplete: () => FocusScope.of(context).nextFocus(),
                        onChanged: (value) {
                          buisnessNickname = value.trim();
                        },
                      ),
                      const SizedBox(height: 8),
                      PasswordTextField(
                        title: "Api Key",
                        onChanged: (value) {
                          apiKey = value.trim();
                        },
                      ),

                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<ActivationCubit>().activate(apiKey, buisnessNickname);
                            },
                            icon: const Icon(Icons.lock_open_rounded),
                            label: const Text("Activar"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
