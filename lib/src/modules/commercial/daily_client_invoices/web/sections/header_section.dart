part of '../daily_client_invoices_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  UserInDb? currentSelectedUser;

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadDailyClientInvoicesCubit>();
    return Card(
      key: ValueKey(readCubit.state),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      readCubit.clearFilters();
                      currentSelectedUser = null;
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text("Limpiar Filtros"),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: DatePickerListTile(
                      key: ValueKey("start_date_${readCubit.startDate.hashCode}"),
                      defaultDate: readCubit.startDate,
                      title: "Fecha Inicio",
                      onSelected: (value) {
                        readCubit.startDate = value;
                      },
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: DatePickerListTile(
                      key: ValueKey("end_date_${readCubit.endDate.hashCode}"),
                      defaultDate: readCubit.endDate,
                      title: "Fecha Fin",
                      onSelected: (value) {
                        readCubit.endDate = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () async {
                          final user = await showActiveUserSelectionDialog(context);
                          if (user == null) return;
                          readCubit.userCreatorId = user.id;
                          currentSelectedUser = user;
                          setState(() {});
                        },
                        child: currentSelectedUser == null
                            ? const Text("Seleccionar Usuario")
                            : Text(currentSelectedUser!.username),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (readCubit.state is ReadDailyClientInvoicesSuccess) ...[
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.tertiary,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final state = readCubit.state as ReadDailyClientInvoicesSuccess;

                            final template = InvoiceByUserTemplate(
                              title: "Ventas por Factura",
                              userInfo: currentSelectedUser != null
                                  ? UserInfo(id: currentSelectedUser!.id, name: currentSelectedUser!.username)
                                  : null,
                              startDate: readCubit.startDate,
                              endDate: readCubit.endDate,
                              count: state.totalCount,
                              total: state.totals.total,
                              items: state.invoices,
                            );

                            await PdfExportTool.export(
                              template,
                              fileName: "ventas_por_factura.pdf",
                            );
                          },
                          label: const Text("Exportar"),
                          icon: const Icon(Icons.picture_as_pdf),
                        ),
                        const SizedBox(width: 8),
                      ],
                      FilledButton.icon(
                        onPressed: () {
                          readCubit.loadPaidInvoices();
                        },
                        label: const Text("Filtrar"),
                        icon: const Icon(Icons.filter_alt_rounded),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
