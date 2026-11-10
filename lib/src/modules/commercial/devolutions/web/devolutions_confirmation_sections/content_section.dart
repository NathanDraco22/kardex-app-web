part of '../devolutions_confirmation_screen.dart';

class _ContentSection extends StatelessWidget {
  const _ContentSection({required this.items});
  final List<SaleItem> items;

  @override
  Widget build(BuildContext context) {
    final totalDevolution = items.fold<int>(0, (sum, item) => sum + item.total);
    final totalFormatted = NumberFormatter.convertToMoneyLike(totalDevolution);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Productos a Devolver', style: Theme.of(context).textTheme.titleLarge),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                final priceFormatted = NumberFormatter.convertToMoneyLike(item.price * item.conversionFactor);
                final subtotalFormatted = NumberFormatter.convertToMoneyLike(item.total);

                return ListTile(
                  title: Text(item.product.name),
                  subtitle: Text('Cantidad: ${item.formattedDisplayQuantity} x $priceFormatted'),
                  trailing: Text(subtotalFormatted),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Total de Devolución: ', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  totalFormatted,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
