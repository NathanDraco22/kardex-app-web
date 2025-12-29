part of '../current_tranfers_screen_web.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<ReadTransfersCubit>();
    final currentFilter = cubit.currentFilterType;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text(
              "Filtro:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            SizedBox(
              width: 200,
              child: DropdownButtonFormField<TransferFilterType>(
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                initialValue: currentFilter,
                items: const [
                  DropdownMenuItem(
                    value: TransferFilterType.sent,
                    child: Text("Enviados"),
                  ),
                  DropdownMenuItem(
                    value: TransferFilterType.received,
                    child: Text("Recibidos"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    cubit.setFilterType(value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
