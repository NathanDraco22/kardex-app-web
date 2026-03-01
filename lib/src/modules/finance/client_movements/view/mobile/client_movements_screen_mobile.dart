import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/client_transaction/read_client_transaction_cubit.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/modules/finance/client_movements/view/widgets/movement_mobile_row.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';

import 'package:kardex_app_front/widgets/widgets.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class ClientMovementsScreenMobile extends StatelessWidget {
  const ClientMovementsScreenMobile({super.key, this.initialClient});

  final ClientInDb? initialClient;

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
      appBar: AppBar(title: const Text("Movimientos de Cliente")),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final maxScrollExtend = notification.metrics.maxScrollExtent;
        final scrollOffset = notification.metrics.pixels;
        final nextPageThreshold = maxScrollExtend * 0.65;

        if (scrollOffset >= nextPageThreshold) {
          context.read<ReadClientTransactionCubit>().getNextPage();
        }
        return false;
      },
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 100,
                  child: _HeaderSection(
                    initialClient:
                        (context.findAncestorWidgetOfExactType<ClientMovementsScreenMobile>())?.initialClient,
                  ),
                ),
                const Expanded(
                  child: Card(
                    child: _ContentSection(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
