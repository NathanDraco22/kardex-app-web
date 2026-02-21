import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/constants/const_modules.dart';
import 'package:kardex_app_front/src/domain/repositories/client_group_repository.dart';
import 'package:kardex_app_front/src/domain/repositories/client_repository.dart';

import 'package:kardex_app_front/src/tools/constant.dart';
import 'package:kardex_app_front/widgets/no_item.dart';
import 'package:kardex_app_front/widgets/row_widgets/mobile_row.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

import '../cubit/client_read_cubit.dart';
import '../cubit/client_write_cubit.dart';
import '../dialogs/create_client_dialog.dart';
import 'widgets/clients_table.dart';

part 'web/cliente_catalog_web.dart';
part 'mobile/client_catalog_mobile.dart';

class ClientCatalogScreen extends StatelessWidget {
  const ClientCatalogScreen({super.key});

  static const accessName = Modules.clients;

  @override
  Widget build(BuildContext context) {
    final clientRepo = context.read<ClientsRepository>();
    final clientGroupRepo = context.read<ClientGroupsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ReadClientCubit(clientRepo, clientGroupRepo)..loadAllClients()),
        BlocProvider(create: (context) => WriteClientCubit(clientRepo)),
      ],
      child: const _BaseScaffold(),
    );
  }
}

class _BaseScaffold extends StatelessWidget {
  const _BaseScaffold();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);

    if (screenSize.width < maxPhoneScreenWidth) return const ClientCatalogMobile();
    return const ClientCatalogWeb();
  }
}
