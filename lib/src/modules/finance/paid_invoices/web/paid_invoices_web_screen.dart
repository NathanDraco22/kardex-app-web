import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/finance/paid_invoices/cubit/read_paid_invoices_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/inspectors/invoice_inspector.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class PaidInvoicesWebScreen extends StatelessWidget {
  const PaidInvoicesWebScreen({super.key});

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

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 160,
              child: _HeaderSection(),
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
