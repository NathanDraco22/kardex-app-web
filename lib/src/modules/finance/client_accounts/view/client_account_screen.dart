import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/client_repository.dart';
import 'package:kardex_app_front/src/modules/finance/client_movements/view/client_movements_screen.dart';

import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/no_item.dart';
import 'package:kardex_app_front/widgets/row_widgets/mobile_row.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

import '../cubit/client_read_cubit.dart';
import '../cubit/client_write_cubit.dart';
import 'widgets/clients_table.dart';

part 'web/cliente_catalog_web.dart';
part 'mobile/client_catalog_mobile.dart';

class ClientAccountScreen extends StatelessWidget {
  const ClientAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clientRepo = context.read<ClientsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ReadClientCubit(clientRepo)..loadAllClients()),
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

    if (screenSize.width < maxPhoneScreenWidth) return const ClientAccountMobile();
    return const ClientAccountWeb();
  }
}
