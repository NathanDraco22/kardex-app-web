import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/invoice_by_product/read_invoice_by_product_cubit.dart';
import 'package:kardex_app_front/src/domain/models/common/sale_item_model.dart';
import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/widgets/basic_table_listview.dart';
import 'package:kardex_app_front/widgets/date_picker_listile.dart';
import 'package:kardex_app_front/widgets/dialogs/viewers/invoice_viewer.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/custom_product_search_delegate.dart';
import 'package:kardex_app_front/widgets/dialogs/search_products/basic_search/widgets/display_product_code.dart';
import 'package:kardex_app_front/widgets/no_item.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class InvoiceByProductWebScreen extends StatefulWidget {
  const InvoiceByProductWebScreen({super.key});

  @override
  State<InvoiceByProductWebScreen> createState() => _InvoiceByProductWebScreenState();
}

class _InvoiceByProductWebScreenState extends State<InvoiceByProductWebScreen> {
  ProductInDb? selectedProduct;

  @override
  Widget build(BuildContext context) {
    EdgeInsets mainPadding = const EdgeInsets.all(4.0);

    if (context.isMobile()) {
      mainPadding = EdgeInsets.zero;
    }

    return Center(
      child: Padding(
        padding: mainPadding,
        child: Column(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _HeaderSection(
              selectedProduct: selectedProduct,
              onProductSelected: (product) {
                setState(() {
                  selectedProduct = product;
                });
              },
            ),
            Expanded(
              child: _ContentSection(
                selectedProduct: selectedProduct,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
