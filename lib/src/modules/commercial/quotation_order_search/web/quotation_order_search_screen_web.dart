import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/widgets/custom_order_list_tile.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/commercial/quotation_order_search/cubit/read_quotation_order_search_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/current_proforma/web/invoice_creator/invoice_creator_screen.dart';
import 'package:kardex_app_front/src/modules/commercial/current_orders/web/invoice_creator/invoice_creator_screen.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/client_selection_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/selectors/user_selection_dialog.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/orders_by_user_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';

part 'sections/header_section.dart';
part 'sections/content_section.dart';

class QuotationOrderSearchScreenWeb extends StatelessWidget {
  const QuotationOrderSearchScreenWeb({super.key});

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
    final readCubit = context.watch<ReadQuotationOrderSearchCubit>();
    final state = readCubit.state;

    return BottomAppBar(
      height: 60,
      child: Builder(
        builder: (context) {
          if (state is! ReadQuotationOrderSearchSuccess) return const SizedBox.shrink();
          final formattedTotal = NumberFormatter.convertToMoneyLike(state.totalAmount);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              TitleLabel(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: "Monto Total",
                bigTitle: formattedTotal,
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
    EdgeInsets mainPadding = const EdgeInsets.all(4.0);

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
