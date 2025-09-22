part of '../current_orders_web_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection();

  @override
  Widget build(BuildContext context) {
    final colorsMap = {
      OrderStatus.open: Colors.blue.shade400,
      OrderStatus.completed: Colors.green.shade400,
      OrderStatus.cancelled: Colors.red.shade400,
    };
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
              return ListTile(
                tileColor: tileColor,
                onTap: () async {
                  await showOrderInvoiceCreatorDialog(context, currentOrder);
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
                        decoration: currentOrder.status != OrderStatus.open ? TextDecoration.lineThrough : null,
                      ),
                    ),

                    const Spacer(),
                    Text(
                      NumberFormatter.convertToMoneyLike(
                        currentOrder.total,
                      ),
                      style: TextStyle(
                        decoration: currentOrder.status != OrderStatus.open ? TextDecoration.lineThrough : null,
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
          );
        },
      ),
    );
  }
}
