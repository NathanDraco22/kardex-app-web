part of '../quotation_order_search_screen_web.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadQuotationOrderSearchCubit>();
    final state = readCubit.state;

    return Card(
      child: Column(
        children: [
          Builder(
            builder: (context) {
              if (state is ReadQuotationOrderSearchLoading ||
                  state is ReadQuotationOrderSearchLoadingMore) {
                return const LinearProgressIndicator();
              }
              return const SizedBox.shrink();
            },
          ),
          Builder(
            builder: (context) {
              if (state is ReadQuotationOrderSearchError) {
                return Expanded(
                  child: Center(
                    child: Text(
                      "Error al cargar los documentos: ${state.message}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              if (state is! ReadQuotationOrderSearchSuccess) {
                return const SizedBox.shrink();
              }

              final orders = state.orders;

              if (orders.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: Text("No hay cotizaciones/órdenes para los filtros"),
                  ),
                );
              }

              return Expanded(
                child: ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final tileColor = index.isOdd ? Colors.white : Colors.grey.shade200;
                    final currentOrder = orders[index];

                    return CustomOrderListTile(
                      backgroundColor: tileColor,
                      order: currentOrder,
                      onTap: () async {
                        final OrderInDb? result;
                        if (currentOrder.status == OrderStatus.draft) {
                          result = await showProformaInvoiceCreatorDialog(context, currentOrder);
                        } else {
                          result = await showOrderInvoiceCreatorDialog(context, currentOrder);
                        }
                        if (!context.mounted) return;
                        if (result == null) return;
                        readCubit.updateOrderInCache(result);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}