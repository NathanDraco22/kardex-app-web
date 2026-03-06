import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/user/user_model.dart';
import 'package:kardex_app_front/src/modules/commercial/daily_product_sales/cubit/read_daily_product_sales_cubit.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/basic_table_listview.dart';
import 'package:kardex_app_front/widgets/date_picker_button.dart';
import 'package:kardex_app_front/widgets/dialogs/user_selection_dialog.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/src/tools/exports/csv_export_tool.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class DailyProductSalesScreenWeb extends StatelessWidget {
  const DailyProductSalesScreenWeb({super.key});

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
    final readCubit = context.watch<ReadDailyProductSalesCubit>();
    final state = readCubit.state;

    return BottomAppBar(
      height: 60,
      child: Builder(
        builder: (context) {
          if (state is! ReadDailyProductSalesSuccess) return const SizedBox.shrink();
          final totalAmount = state.totalAmount;
          final formattedTotalPaid = NumberFormatter.convertToMoneyLike(totalAmount);
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              TitleLabel(
                crossAxisAlignment: CrossAxisAlignment.center,
                title: "Monto Total",
                bigTitle: formattedTotalPaid,
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
