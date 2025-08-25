part of '../current_inventory_screen_web.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final readCubit = context.read<ReadCurrentInventoryCubit>();
    final state = readCubit.state as ReadCurrentInventorySuccess;
    final totalInventory = NumberFormatter.convertToMoneyLike(state.total);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Productos: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: state.inventories.length.toString()),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Total: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: totalInventory),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
