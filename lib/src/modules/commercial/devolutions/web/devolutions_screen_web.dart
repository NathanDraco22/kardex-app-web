import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/invoice_by_user_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/basic_table_listview.dart';
import 'package:kardex_app_front/widgets/date_picker_listile.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/user_selection_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';
import 'package:kardex_business/kardex_business.dart';

import '../cubit/read_devolutions_cubit.dart';
import 'devolutions_selection_screen.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class DevolutionsScreenWeb extends StatelessWidget {
  const DevolutionsScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadDevolutionsCubit>();
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return Scaffold(
      floatingActionButton: Builder(
        builder: (context) {
          if (readCubit.state is! ReadDevolutionsSearchResult) {
            return const SizedBox.shrink();
          }

          if (viewInsets.bottom > 0) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: () {
              final state = readCubit.state as ReadDevolutionsSearchResult;
              if (state.invoice.clientId != kSaleClientId && state.invoice.amountPaid > 0) {
                DialogManager.showInfoDialog(context, "Los clientes de crédito con facturas abonadas no pueden hacer devoluciones de productos");
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DevolutionsSelectionScreen(
                    invoice: state.invoice,
                    devolutions: state.devolutions,
                  ),
                ),
              );
            },
            label: const Text(
              "Hacer Devolución",
            ),
          );
        },
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    EdgeInsets mainPadding = const EdgeInsets.all(4.0);

    if (context.isMobile()) {
      mainPadding = EdgeInsets.zero;
    }

    return Center(
      child: Padding(
        padding: mainPadding,
        child: const Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderSection(),
            Expanded(
              child: _ContentSection(),
            ),
          ],
        ),
      ),
    );
  }
}
