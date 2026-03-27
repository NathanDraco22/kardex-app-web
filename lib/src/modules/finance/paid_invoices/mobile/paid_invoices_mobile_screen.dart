import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/finance/paid_invoices/cubit/read_paid_invoices_cubit.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/basic_table_listview.dart';
import 'package:kardex_app_front/widgets/dialogs/invoice_inspector.dart';
import 'package:kardex_app_front/widgets/super_widgets/custom_autocomplete_textfield.dart';
import 'package:kardex_app_front/widgets/date_picker_listile.dart';
import 'package:kardex_app_front/widgets/title_label.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class PaidInvoicesMobileScreen extends StatelessWidget {
  const PaidInvoicesMobileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _Body(),
      bottomNavigationBar: _BottomAppBar(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              child: Center(
                child: _HeaderSection(),
              ),
            ),
            Expanded(
              child: _ContentSection(),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadPaidInvoicesCubit>();
    final state = readCubit.state;

    return BottomAppBar(
      height: 60,
      child: Builder(
        builder: (context) {
          if (state is! ReadPaidInvoicesSuccess) return const SizedBox.shrink();
          final totalCost = state.totals.totalCost;
          final totalAmount = state.totals.total;
          final totalUtility = totalAmount - totalCost;
          final formattedTotalCost = NumberFormatter.convertToMoneyLike(totalCost);
          final formattedTotalPaid = NumberFormatter.convertToMoneyLike(totalAmount);
          final formattedUtility = NumberFormatter.convertToMoneyLike(totalUtility);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              TitleLabel(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: "Costo",
                bigTitle: formattedTotalCost,
              ),
              TitleLabel(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: "Monto",
                bigTitle: formattedTotalPaid,
              ),

              TitleLabel(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: "Utilidad",
                bigTitle: formattedUtility,
              ),
            ],
          );
        },
      ),
    );
  }
}
