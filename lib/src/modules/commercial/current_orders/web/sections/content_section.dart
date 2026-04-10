part of '../current_orders_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: BlocBuilder<ReadOrderCubit, ReadOrderState>(
        builder: (context, state) {
          if (state is ReadOrderLoading || state is ReadOrderInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ReadOrderError) {
            return Center(
              child: Text(state.message),
            );
          }

          state as ReadOrderSuccess;

          final orders = state.orders;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final tileColor = index.isOdd ? Colors.white : Colors.grey.shade200;
              final currentOrder = orders[index];
              return CustomOrderListTile(
                backgroundColor: tileColor,
                order: currentOrder,
                onTap: () async {
                  await showOrderInvoiceCreatorDialog(context, currentOrder);
                },
              );
            },
          );
        },
      ),
    );
  }
}
