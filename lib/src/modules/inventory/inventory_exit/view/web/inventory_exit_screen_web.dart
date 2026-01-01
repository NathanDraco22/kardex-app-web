import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/domain/models/common/user_info.dart';
import 'package:kardex_app_front/src/domain/models/models.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/cubit/write_exit_doc_cubit.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/session_tool.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/search_product_in_branch_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

import '../mediator.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class InventoryExitScreenWeb extends StatelessWidget {
  const InventoryExitScreenWeb({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final mediator = InventoryExitMediator.read(context)!;
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyG, control: true): () => saveExit(context),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("Salida de Inventario"),
            leading: IconButton(
              onPressed: () async {
                final allFields = mediator.hasAllRequiredFields();
                if (!allFields) {
                  context.pop();
                  return;
                }
                final res = await DialogManager.confirmActionDialog(
                  context,
                  "Deseas salir sin guardar? (Perderas los cambios)",
                );
                if (res != true) return;
                if (!context.mounted) return;
                context.pop();
              },
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: const _WebBody(),
        ),
      ),
    );
  }
}

class _WebBody extends StatelessWidget {
  const _WebBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 160,
              child: _HeaderSection(),
            ),
            SizedBox(height: 8),
            Flexible(
              fit: FlexFit.tight,
              child: _ContentSection(),
            ),
          ],
        ),
      ),
    );
  }
}
