import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/settings/view/users/cubit/read_user_cubit.dart';
import 'package:kardex_app_front/src/modules/settings/view/users/dialog/create_user_dialog.dart';
import 'package:kardex_app_front/src/modules/settings/view/users/dialog/update_user_dialog.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

class UsersWebScreen extends StatelessWidget {
  const UsersWebScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ReadUserCubit, ReadUserState>(
        builder: (context, state) {
          if (state is ReadUserLoading || state is ReadUserInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReadUserError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const _Body();
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadUserCubit>();
    final state = readCubit.state as ReadUserSuccess;
    final users = state.users;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Column(
            children: [
              const SizedBox(height: 6),

              Row(
                children: [
                  const Spacer(),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await showCreateUserDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Agregar Nuevo Usuario"),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              const SizedBox(height: 12),

              const Divider(),

              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final currentUser = users[index];

                    final created = DateTimeTool.formatddMMyy(currentUser.createdAt);

                    Color tileColor = Colors.white;
                    if (index % 2 == 0) {
                      tileColor = Colors.grey.shade200;
                    }

                    if (state is HighlightedUser) {
                      if (state.updatedUsers.any((element) => element.id == currentUser.id)) {
                        tileColor = Colors.blue.shade100;
                      } else if (state.newUsers.any((element) => element.id == currentUser.id)) {
                        tileColor = Colors.yellow.shade200;
                      }
                    }

                    return ListTile(
                      leading: SizedBox(
                        width: 80,
                        child: Center(
                          child: Text(
                            currentUser.userRole.name,
                            style: TextStyle(
                              color: Colors.blueGrey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      tileColor: tileColor,
                      title: Text(
                        "${currentUser.id} - ${currentUser.username}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          StatusTagLabel(
                            isActive: currentUser.isActive,
                            label: currentUser.isActive ? "Activo" : "Inactivo",
                          ),
                          Text(
                            "Creado: $created",
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: () async {
                          await showUpdateUserDialog(context, currentUser);
                        },
                        icon: const Icon(Icons.edit),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
