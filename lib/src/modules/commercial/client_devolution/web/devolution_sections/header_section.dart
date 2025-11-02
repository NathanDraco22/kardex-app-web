part of '../devolution_selection_screen.dart';

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.invoice});
  final InvoiceInDb invoice;

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();
    final branch = authState.branch;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Factura",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "No. ${invoice.docNumber}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          DateTimeTool.formatddMMyy(invoice.createdAt),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          DateTimeTool.formatHHmm(invoice.createdAt),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),

                Builder(
                  builder: (context) {
                    String paymentType = "CREDITO";

                    if (invoice.paymentType == PaymentType.cash) {
                      paymentType = "CONTADO";
                    }

                    return Text(
                      paymentType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),
                Text(
                  branch.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "Cliente: ${invoice.clientInfo.name}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),

                Row(
                  children: [
                    Text(
                      "Elaborado por: ${invoice.createdBy.name}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
