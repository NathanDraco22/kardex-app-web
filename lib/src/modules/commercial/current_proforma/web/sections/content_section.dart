part of '../current_proforma_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final colorsMap = {
      OrderStatus.open: Colors.blue.shade400,
      OrderStatus.completed: Colors.green.shade400,
      OrderStatus.cancelled: Colors.red.shade400,
      OrderStatus.draft: Colors.orange.shade400,
    };
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
              return cubit.loadPaginatedOrders();
            },
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final tileColor = index.isOdd ? Colors.white : Colors.grey.shade200;
                final currentOrder = orders[index];
                return ListTile(
                  tileColor: tileColor,
                  onTap: () async {
                    await showProformaInvoiceCreatorDialog(context, currentOrder);
                  },
                  leading: Container(
                    width: 85,
                    height: 30,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorsMap[currentOrder.status],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentOrder.status.tag,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        currentOrder.clientInfo.name,
                        style: TextStyle(
                          decoration: currentOrder.status == OrderStatus.cancelled ? TextDecoration.lineThrough : null,
                        ),
                      ),

                      const Spacer(),
                      Text(
                        NumberFormatter.convertToMoneyLike(
                          currentOrder.total,
                        ),
                        style: TextStyle(
                          decoration: currentOrder.status == OrderStatus.cancelled ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        DateTimeTool.formatddMMyy(
                          currentOrder.createdAt,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(width: 12),
                      Text(
                        "# ${currentOrder.docNumber}",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
