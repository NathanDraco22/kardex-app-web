import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/widgets/dialogs/invoice_viewer.dart';

import '../cubit/read_anon_invoices_cubit.dart';
import 'anon_devolution_selection_screen.dart';

part 'sections/content_section.dart';
part 'sections/header_section.dart';

class AnonDevolutionScreenWeb extends StatelessWidget {
  const AnonDevolutionScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadAnonInvoicesCubit>();
    final viewInsets = MediaQuery.viewInsetsOf(context);
    return Scaffold(
      floatingActionButton: Builder(
        builder: (context) {
          if (readCubit.state is! ReadAnonInvoicesSuccess) {
            return const SizedBox.shrink();
          }

          if (viewInsets.bottom > 0) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed: () {
              final state = readCubit.state as ReadAnonInvoicesSuccess;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AnonDevolutionSelectionScreen(
                    invoice: state.invoice,
                    devolutions: state.devolutions,
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
      appBar: AppBar(
        title: const Text("Devolución de Productos"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _HeaderSection(),
          SizedBox(height: 4),
          Expanded(
            child: _ContentSection(),
          ),
        ],
      ),
    );
  }
}
