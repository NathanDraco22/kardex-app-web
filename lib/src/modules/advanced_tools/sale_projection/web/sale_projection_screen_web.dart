import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/advanced_tools/sale_projection/cubits/export_excel_cubit.dart';
import 'package:kardex_app_front/src/modules/advanced_tools/sale_projection/cubits/read_sale_projection_cubit.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/src/tools/number_formatter.dart';
import 'package:kardex_app_front/widgets/dialogs/branch_selection_dialog.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch_model.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class SaleProjectionScreenWeb extends StatefulWidget {
  const SaleProjectionScreenWeb({super.key});

  @override
  State<SaleProjectionScreenWeb> createState() => _SaleProjectionScreenWebState();
}

class _SaleProjectionScreenWebState extends State<SaleProjectionScreenWeb> {
  int projectionDays = 30;

  void updateProjectionDays(int days) {
    setState(() {
      projectionDays = days;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _RootScaffold(
      projectionDays: projectionDays,
      onDaysChanged: updateProjectionDays,
    );
  }
}

class _RootScaffold extends StatelessWidget {
  final int projectionDays;
  final ValueChanged<int> onDaysChanged;

  const _RootScaffold({
    required this.projectionDays,
    required this.onDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExportExcelCubit, ExportExcelState>(
      listener: (context, state) async {
        if (state is ExportExcelLoading) {
          await LoadingDialogManager.showLoadingDialog(context);
        }
        if (state is ExportExcelSuccess) {}
        if (state is ExportExcelFailure) {
          if (!context.mounted) return;
          await DialogManager.showErrorDialog(context, state.message);
        }
        if (!context.mounted) return;
        LoadingDialogManager.closeLoadingDialog(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Proyección de Ventas'),
        ),
        body: _Body(
          projectionDays: projectionDays,
          onDaysChanged: onDaysChanged,
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final int projectionDays;
  final ValueChanged<int> onDaysChanged;

  const _Body({
    required this.projectionDays,
    required this.onDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 100,
              child: _HeaderSection(
                projectionDays: projectionDays,
                onDaysChanged: onDaysChanged,
              ),
            ),
            Expanded(
              child: _ContentSection(
                projectionDays: projectionDays,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
