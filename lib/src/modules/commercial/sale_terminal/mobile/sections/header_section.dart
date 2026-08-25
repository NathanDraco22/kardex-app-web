part of '../sale_terminal_screen_mobile.dart';

class _MobileHeaderSection extends StatefulWidget {
  const _MobileHeaderSection();

  @override
  State<_MobileHeaderSection> createState() => _MobileHeaderSectionState();
}

class _MobileHeaderSectionState extends State<_MobileHeaderSection> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewController = SaleTerminalMobileMediator.of(context).viewController;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: ListenableBuilder(
          listenable: viewController,
          builder: (context, _) {
            final client = viewController.selectedClient;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Client selector bar
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    if (client == null) {
                      final selected = await showClientSelectionDialog(context);
                      if (selected != null) {
                        viewController.selectedClient = selected;
                      }
                    } else {
                      showClientFullDetailsDialog(context, client: client);
                    }
                  },
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: client == null ? Colors.grey.shade100 : Colors.blue.shade50,
                      border: Border.all(
                        color: client == null ? Colors.grey.shade300 : Colors.blue.shade200,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 16,
                          color: client == null ? Colors.grey.shade700 : Colors.blue.shade700,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            client == null ? "Consumidor Final" : client.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: client == null ? Colors.grey.shade800 : Colors.blue.shade900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (client != null) ...[
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              viewController.selectedClient = null;
                            },
                          ),
                        ] else ...[
                          Text(
                            "Cambiar",
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Search bar
                SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _searchController,
                    focusNode: viewController.searchFocusNode,
                    autofocus: false,
                    textInputAction: TextInputAction.search,
                    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                    onSubmitted: (value) {
                      _debounce?.cancel();
                      processTerminalSearch(
                        context: context,
                        value: value,
                        viewController: viewController,
                        searchController: _searchController,
                        isSubmitted: true,
                        onCleared: () => setState(() {}),
                      );
                    },
                    decoration: InputDecoration(
                      isCollapsed: true,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              focusNode: FocusNode(canRequestFocus: false),
                              icon: const Icon(Icons.clear, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                context.read<ReadTerminalProductCubit>().searchProducts('');
                                setState(() {});
                              },
                            )
                          : null,
                      hintText: "Buscar por nombre o código...",
                      hintStyle: const TextStyle(fontSize: 12),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {});
                      _debounce?.cancel();
                      _debounce = Timer(
                        const Duration(milliseconds: 350),
                        () {
                          if (!mounted) return;
                          processTerminalSearch(
                            context: context,
                            value: value,
                            viewController: viewController,
                            searchController: _searchController,
                            isSubmitted: false,
                            onCleared: () => setState(() {}),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 6),
                // Price level & unit controls row
                Focus(
                  canRequestFocus: false,
                  descendantsAreFocusable: false,
                  child: Row(
                    children: [
                      // Price Level dropdown
                      Expanded(
                        flex: 50,
                        child: Container(
                          height: 34,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: viewController.selectedPriceLevel,
                              isDense: true,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down, size: 16),
                              items: const [
                                DropdownMenuItem(value: 1, child: Text("Nivel 1", style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(value: 2, child: Text("Nivel 2", style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(value: 3, child: Text("Nivel 3", style: TextStyle(fontSize: 12))),
                                DropdownMenuItem(value: 4, child: Text("Nivel 4", style: TextStyle(fontSize: 12))),
                              ],
                              onChanged: (val) {
                                if (val != null) viewController.selectedPriceLevel = val;
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Unit mode segmented button
                      Expanded(
                        flex: 50,
                        child: SegmentedButton<bool>(
                          showSelectedIcon: false,
                          style: SegmentedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          segments: const [
                            ButtonSegment(
                              value: false,
                              label: Text("Detalle"),
                            ),
                            ButtonSegment(
                              value: true,
                              label: Text("Mayorista"),
                            ),
                          ],
                          selected: {viewController.isWholesale},
                          onSelectionChanged: (selection) {
                            viewController.isWholesale = selection.first;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
