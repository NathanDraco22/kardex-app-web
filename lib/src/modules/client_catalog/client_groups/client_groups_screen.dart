import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/client_group_cubit/read_client_group_cubit.dart';
import 'package:kardex_app_front/src/modules/client_catalog/client_groups/dialog/client_group_form_dialog.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';

part 'web/client_groups_screen_web.dart';

class ClientGroupsScreen extends StatefulWidget {
  const ClientGroupsScreen({super.key});

  @override
  State<ClientGroupsScreen> createState() => _ClientGroupsScreenState();
}

class _ClientGroupsScreenState extends State<ClientGroupsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReadClientGroupCubit>().ensureLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return const ClientGroupsScreenWeb();
  }
}
