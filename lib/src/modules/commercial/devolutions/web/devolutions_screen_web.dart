import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/invoice_by_user_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

import '../cubit/read_devolutions_cubit.dart';
import '../devolution_eligibility.dart';
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
            onPressed: () async {
              final state = readCubit.state as ReadDevolutionsSearchResult;
              final errorMsg = validateInvoiceForDevolution(state.invoice);
              if (errorMsg != null) {
                DialogManager.showInfoDialog(context, errorMsg);
                return;
              }
              final creditNotesRepo = context.read<CreditNotesRepository>();
              final creditNotes = await creditNotesRepo
                  .getCreditNotesByInvoiceId(state.invoice.id)
                  .catchError((_) => const <CreditNoteInDb>[]);
              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DevolutionsSelectionScreen(
                    invoice: state.invoice,
                    devolutions: state.devolutions,
                    creditNotes: creditNotes,
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

    if (context.isMobileOrTablet()) {
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
