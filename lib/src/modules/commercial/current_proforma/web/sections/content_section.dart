part of '../current_proforma_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: BlocBuilder<ReadProformaCubit, ReadProformaState>(
        builder: (context, state) {
          if (state is ReadProformaLoading || state is ReadProformaInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReadProformaError) {
            return Center(
              child: Text(state.message),
            );
          }

          state as ReadProformaSuccess;

          final orders = state.orders;

          if (orders.isEmpty) {
            return const Center(child: Text("No hay cotizaciones"));
          }

          return RefreshIndicator(
            onRefresh: () {
              final cubit = context.read<ReadProformaCubit>();
              return cubit.loadPaginatedOrders(getIt<AuthCubit>().currentBranchId);
            },
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final tileColor = index.isOdd ? Colors.white : Colors.grey.shade200;
                final currentOrder = orders[index];
                return CustomOrderListTile(
                  order: currentOrder,
                  backgroundColor: tileColor,
                  onTap: () async {
                    await showProformaInvoiceCreatorDialog(context, currentOrder);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
