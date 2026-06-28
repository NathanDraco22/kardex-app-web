import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/cubits/invoice_by_product/read_invoice_by_product_cubit.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/modules/commercial/invoice_by_product/web/invoice_by_product_web_screen.dart';

class InvoiceByProductScreen extends StatelessWidget {
  const InvoiceByProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final invoiceRepo = context.read<InvoicesRepository>();

    return BlocProvider(
      create: (context) => ReadInvoiceByProductCubit(invoiceRepo),
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final scrollOffset = notification.metrics.pixels;
        final maxScrollExtent = notification.metrics.maxScrollExtent;
        if (scrollOffset >= maxScrollExtent * 0.65) {
          context.read<ReadInvoiceByProductCubit>().nextPage();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Buscar facturas por producto"),
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
    return const InvoiceByProductWebScreen();
  }
}
