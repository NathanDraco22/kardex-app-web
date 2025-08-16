import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/cubits/config_app/config_app_cubit.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/models/exit_doc/exit_doc_model.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/cubit/write_exit_doc_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/inventory_exit/view/mediator.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/custom_autocomplete_textfield.dart';
import 'package:kardex_app_front/widgets/empty_scaffold.dart';
import 'package:kardex_app_front/widgets/tables/inventory_movement_product_table.dart';
import 'package:kardex_app_front/widgets/text_field_date_selector.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class InventoryExitScreen extends StatefulWidget {
  const InventoryExitScreen({super.key});

  @override
  State<InventoryExitScreen> createState() => _InventoryExitScreenState();
}

class _InventoryExitScreenState extends State<InventoryExitScreen> {
  late InventoryExitNotifier notifier;

  bool rebuildScreen = false;

  @override
  void initState() {
    notifier = InventoryExitNotifier();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (rebuildScreen) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        rebuildScreen = false;
        setState(() {});
      });
      return const EmptyScaffold();
    }

    final exitDocRepo = context.read<ExitDocsRepository>();
    return NotificationListener<RebuildScreeenNotification>(
      onNotification: (notification) {
        notifier = InventoryExitNotifier();
        rebuildScreen = true;
        setState(() {});
        return true;
      },
      child: BlocProvider(
        create: (context) => WriteExitDocCubit(exitDocRepo),
        child: InventoryExitMediator(
          notifier: notifier,
          child: const _RootScaffold(),
        ),
      ),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    final mediator = InventoryExitMediator.read(context)!;
    return BlocListener<WriteExitDocCubit, WriteExitDocState>(
      listener: (context, state) {
        if (state is WriteExitDocInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteExitDocError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is WriteExitDocSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showInfoDialog(context, "Salida de inventario guardada");
          if (!context.mounted) return;
          RebuildScreeenNotification().dispatch(context);
        }
      },
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
        body: const _Body(),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
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
