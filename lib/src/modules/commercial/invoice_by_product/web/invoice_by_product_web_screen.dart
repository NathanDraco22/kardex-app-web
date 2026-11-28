import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/invoice_by_product/read_invoice_by_product_cubit.dart';
import 'package:kardex_app_front/src/tools/exports/csv_export_tool.dart';
import 'package:kardex_app_front/src/tools/exports/pdf/templates/product_sales_detail_template.dart';
import 'package:kardex_app_front/src/tools/exports/pdf_export_tool.dart';
import 'package:kardex_app_front/src/tools/role_tools.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/dialogs/export_options_dialog.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/widgets/display_product_code.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';
import 'package:kardex_app_front/widgets/title_label.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class InvoiceByProductWebScreen extends StatefulWidget {
  const InvoiceByProductWebScreen({super.key});

  @override
  State<InvoiceByProductWebScreen> createState() => _InvoiceByProductWebScreenState();
}

class _InvoiceByProductWebScreenState extends State<InvoiceByProductWebScreen> {
  ProductInDb? selectedProduct;

  void _selectProduct(ProductInDb? product) {
    if (selectedProduct?.id == product?.id) return;
    setState(() {
      selectedProduct = product;
    });
    context.read<ReadInvoiceByProductCubit>().resetResults();
  }

  @override
  Widget build(BuildContext context) {
    EdgeInsets mainPadding = const EdgeInsets.all(4.0);

    if (context.isMobileOrTablet()) {
      mainPadding = EdgeInsets.zero;
    }

    return Scaffold(
      body: Center(
        child: Padding(
          padding: mainPadding,
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderSection(
                selectedProduct: selectedProduct,
                onProductSelected: _selectProduct,
              ),
              Expanded(
                child: _ContentSection(
                  selectedProduct: selectedProduct,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomAppBar(),
    );
  }
}

class _BottomAppBar extends StatelessWidget {
  const _BottomAppBar();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ReadInvoiceByProductCubit>().state;

    if (state is! ReadInvoiceByProductSuccess) {
      return const SizedBox.shrink();
    }

    return BottomAppBar(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 24,
        children: [
          TitleLabel(
            crossAxisAlignment: CrossAxisAlignment.center,
            title: "Facturas",
            bigTitle: state.count.toString(),
          ),
          TitleLabel(
            crossAxisAlignment: CrossAxisAlignment.center,
            title: "Monto Total",
            bigTitle: NumberFormatter.convertToMoneyLike(state.summary.total),
          ),
        ],
      ),
    );
  }
}
