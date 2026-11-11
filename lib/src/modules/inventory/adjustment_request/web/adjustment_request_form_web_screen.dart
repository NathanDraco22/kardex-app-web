import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/adjustment_request_form_actions.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/adjustment_request_mediator.dart';
import 'package:kardex_app_front/src/modules/inventory/adjustment_request/widgets/adjustment_request_editor_table.dart';
import 'package:kardex_app_front/widgets/buttons/elevated_ctrl_button.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

part 'sections/form_header_section.dart';
part 'sections/form_content_section.dart';

class AdjustmentRequestFormWebScreen extends StatelessWidget {
  const AdjustmentRequestFormWebScreen({
    super.key,
    required this.editingRequest,
    required this.isEditing,
  });

  final AdjustmentRequestInDb? editingRequest;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return ShortcutContainer(
      child: _WebScaffold(
        editingRequest: editingRequest,
        isEditing: isEditing,
      ),
    );
  }
}

class _WebScaffold extends StatelessWidget {
  const _WebScaffold({
    required this.editingRequest,
    required this.isEditing,
  });

  final AdjustmentRequestInDb? editingRequest;
  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    final viewController = AdjustmentRequestMediator.read(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Solicitud de Ajuste' : 'Nueva Solicitud de Ajuste'),
        leading: IconButton(
          onPressed: () async {
            if (!viewController.hasItems) {
              context.pop();
              return;
            }
            final res = await DialogManager.confirmActionDialog(
              context,
              '¿Deseas salir sin guardar? (Perderás los cambios)',
            );
            if (res != true) return;
            if (!context.mounted) return;
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: _WebBody(editingRequest: editingRequest),
    );
  }
}

class _WebBody extends StatelessWidget {
  const _WebBody({required this.editingRequest});

  final AdjustmentRequestInDb? editingRequest;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 160,
              child: _FormHeaderSection(editingRequest: editingRequest),
            ),
            const SizedBox(height: 8),
            const Flexible(
              fit: FlexFit.tight,
              child: _FormContentSection(),
            ),
          ],
        ),
      ),
    );
  }
}
