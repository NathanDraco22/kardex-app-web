part of '../invoice_by_product_web_screen.dart';

class _HeaderSection extends StatefulWidget {
  final ProductInDb? selectedProduct;
  final ValueChanged<ProductInDb?> onProductSelected;

  const _HeaderSection({
    required this.selectedProduct,
    required this.onProductSelected,
  });

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
  UserInDb? currentSelectedUser;
  ClientInDb? currentSelectedClient;

  @override
  void initState() {
    super.initState();
    final (isSellerRole, userInDb) = RoleTools.isSeller();
    if (isSellerRole) {
      currentSelectedUser = userInDb;
    }
  }

  @override
  Widget build(BuildContext context) {
    final readCubit = context.watch<ReadInvoiceByProductCubit>();
    final (isSellerRole, userInDb) = RoleTools.isSeller();
    if (isSellerRole && currentSelectedUser == null) {
      currentSelectedUser = userInDb;
    }

    final currentState = readCubit.state;
    final canExport =
        currentState is ReadInvoiceByProductSuccess &&
        currentState.count > 0 &&
        widget.selectedProduct != null;

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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: DatePickerListTile(
                      key: ValueKey("start_date_${readCubit.startDate.hashCode}"),
                      defaultDate: readCubit.startDate,
                      title: "Fecha Inicio",
                      onSelected: (value) {
                        if (readCubit.startDate == value) return;
                        readCubit.startDate = value;
                        readCubit.resetResults();
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
                        if (readCubit.endDate == value) return;
                        readCubit.endDate = value;
                        readCubit.resetResults();
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
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  ClientDropdownSelector(
                    width: 280,
                    allowNoClient: true,
                    selectedClient: currentSelectedClient,
                    selectedClientId: readCubit.clientId,
                    onChanged: (client) {
                      currentSelectedClient = client;
                      setState(() {});
                    },
                    onIdChanged: (clientId) {
                      if (readCubit.clientId == clientId) return;
                      readCubit.clientId = clientId;
                      readCubit.resetResults();
                      setState(() {});
                    },
                  ),
                  if (!isSellerRole)
                    UserDropdownSelector(
                      width: 280,
                      selectedUser: currentSelectedUser,
                      onChanged: (user) {
                        if (readCubit.userCreatorId != user?.id) {
                          readCubit.userCreatorId = user?.id;
                          readCubit.resetResults();
                        }
                        currentSelectedUser = user;
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                children: [
                  SecondaryMenuButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () async {
                      final product = await showProductSearchDelegate(context);
                      if (product == null) return;
                      widget.onProductSelected(product);
                    },
                    label: widget.selectedProduct == null
                        ? const Text("Seleccionar Producto")
                        : const Text("Cambiar Producto"),
                  ),
                ],
              ),
            ),
            if (widget.selectedProduct != null) ...[
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DisplayProductCode(product: widget.selectedProduct!),
                    const SizedBox(height: 4),
                    Row(
                      spacing: 8,
                      children: [
                        Text(
                          widget.selectedProduct!.brandName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          widget.selectedProduct!.unitName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (canExport) ...[
                        PrimaryMenuButton(
                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                          foregroundColor: Colors.white,
                          label: const Text("Exportar"),
                          icon: const Icon(Icons.picture_as_pdf),
                          onPressed: () async {
                            final option = await showExportOptionsDialog(context);
                            if (option == null) return;
                            if (!context.mounted) return;

                            final state = readCubit.state;
                            if (state is! ReadInvoiceByProductSuccess) return;

                            final product = widget.selectedProduct;
                            if (product == null || state.count == 0) return;

                            var invoices = state.invoices;
                            if (state.count > invoices.length) {
                              LoadingDialogManager.showLoadingDialog(context);
                              try {
                                invoices = await readCubit.fetchAllInvoicesForExport();
                              } catch (error) {
                                if (context.mounted) {
                                  LoadingDialogManager.closeLoadingDialog(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "No se pudo completar la exportación: $error",
                                      ),
                                    ),
                                  );
                                }
                                return;
                              }
                              if (context.mounted) {
                                LoadingDialogManager.closeLoadingDialog(context);
                              }
                            }
                            if (!context.mounted) return;

                            final uniqueInvoices = <String, InvoiceInDb>{
                              for (final invoice in invoices) invoice.id: invoice,
                            }.values.toList();

                            if (uniqueInvoices.length < state.count) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "La exportación quedó incompleta. Intente nuevamente.",
                                  ),
                                ),
                              );
                              return;
                            }

                            var exportTotal = 0;
                            var exportUnits = 0;
                            for (final invoice in uniqueInvoices) {
                              final line = invoice.productLine(product.id);
                              exportTotal += line.total;
                              exportUnits += line.totalUnits;
                            }

                            if (option == ExportOption.csv) {
                              await CsvExportTool.exportProductSalesDetailToCSV(
                                invoices: uniqueInvoices,
                                product: product,
                                fileName: "ventas_de_un_producto",
                              );
                            } else if (option == ExportOption.pdf) {
                              final clientLabel = state.clientId == kSaleClientId
                                  ? "Sin cliente (Venta libre)"
                                  : currentSelectedClient?.name;

                              final template = ProductSalesDetailTemplate(
                                title: "Ventas de un Producto",
                                branchName: getIt<AuthCubit>().currentBranchName,
                                userInfo: currentSelectedUser != null
                                    ? UserInfo(
                                        id: currentSelectedUser!.id,
                                        name: currentSelectedUser!.username,
                                      )
                                    : null,
                                clientLabel: clientLabel,
                                product: product,
                                startDate: state.startDate,
                                endDate: state.endDate,
                                invoiceCount: uniqueInvoices.length,
                                totalUnits: exportUnits,
                                total: exportTotal,
                                items: uniqueInvoices,
                              );

                              await PdfExportTool.export(
                                template,
                                fileName: "ventas_de_un_producto.pdf",
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                      PrimaryMenuButton(
                        onPressed: widget.selectedProduct == null
                            ? null
                            : () {
                                readCubit.loadInvoicesByProduct(
                                  productId: widget.selectedProduct!.id,
                                  branchId: getIt<AuthCubit>().currentBranchId,
                                );
                              },
                        label: const Text("Filtrar"),
                        icon: const Icon(Icons.filter_alt_rounded),
                      ),
                    ],
                  ),
                  SecondaryMenuButton(
                    onPressed: () {
                      readCubit.clearFilters(getIt<AuthCubit>().currentBranchId);
                      if (!isSellerRole) {
                        currentSelectedUser = null;
                      }
                      currentSelectedClient = null;
                      widget.onProductSelected(null);
                      setState(() {});
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text("Limpiar"),
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
