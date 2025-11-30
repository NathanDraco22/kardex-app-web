part of '../anon_devolution_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    if (authCubit.state is! Authenticated) {
      return const Center(
        child: Text("No autenticado"),
      );
    }
    final readCubit = context.read<ReadAnonInvoicesCubit>();
    final branch = (authCubit.state as Authenticated).branch;
    return Center(
      child: SafeArea(
        child: Card(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder(
                bloc: readCubit,
                builder: (context, state) {
                  if (state is ReadAnonInvoicesInitial) {
                    return const Center(
                      child: Text("Elige una factura"),
                    );
                  }
                  if (state is ReadAnonInvoicesInProgress) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (state is ReadAnonInvoicesError) {
                    return Center(
                      child: Text(state.message),
                    );
                  }
                  state as ReadAnonInvoicesSuccess;

                  final invoice = state.invoice;

                  return InvoiceViewerContent(
                    invoice: invoice,
                    branch: branch,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
