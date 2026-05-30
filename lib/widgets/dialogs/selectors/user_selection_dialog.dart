import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/read_active_users/read_active_users_cubit.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

Future<UserInDb?> showActiveUserSelectionDialog(BuildContext context) async {
  return await showDialog<UserInDb?>(
    context: context,
    builder: (context) => const ActiveUserSelectionDialog(),
  );
}

class ActiveUserSelectionDialog extends StatelessWidget {
  const ActiveUserSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final usersRepo = context.read<UsersRepository>();

    return BlocProvider(
      create: (context) => ReadActiveUsersCubit(
        usersRepository: usersRepo,
      )..loadActiveUsers(),
      child: const _DialogContent(),
    );
  }
}

class _DialogContent extends StatefulWidget {
  const _DialogContent();

  @override
  State<_DialogContent> createState() => _DialogContentState();
}

class _DialogContentState extends State<_DialogContent> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Seleccionar Usuario Activo"),
      content: SizedBox(
        width: 500,
        height: 600,
        child: Column(
          children: [
            SearchFieldDebounced(
              onSearch: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: BlocBuilder<ReadActiveUsersCubit, ReadActiveUsersState>(
                builder: (context, state) {
                  if (state is ReadActiveUsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ReadActiveUsersError) {
                    return Center(child: Text("Error: ${state.message}"));
                  }

                  if (state is ReadActiveUsersSuccess) {
                    final users = state.users.where((user) {
                      return user.username.toLowerCase().contains(searchQuery);
                    }).toList();

                    if (users.isEmpty) {
                      return const Center(child: Text("No se encontraron usuarios"));
                    }

                    return ListView.separated(
                      itemCount: users.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(user.username.substring(0, 1).toUpperCase()),
                          ),
                          title: Text(user.username),
                          subtitle: Text(user.role),
                          onTap: () {
                            Navigator.pop(context, user);
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
      ],
    );
  }
}
