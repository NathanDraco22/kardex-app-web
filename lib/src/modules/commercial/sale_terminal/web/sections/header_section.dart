part of '../sale_terminal_screen_web.dart';

class _HeaderSection extends StatefulWidget {
  const _HeaderSection();

  @override
  State<_HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<_HeaderSection> {
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
    final viewController = SaleTerminalWebMediator.of(context).viewController;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListenableBuilder(
          listenable: viewController,
          builder: (context, _) {
            final client = viewController.selectedClient;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: ClientSelectorCard(
                          key: ValueKey(client?.id ?? 'no-client'),
                          initialClient: client,
                          onChange: (value) => viewController.selectedClient = value,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 48,
                        child: TextField(
                          controller: _searchController,
                          focusNode: viewController.searchFocusNode,
                          autofocus: true,
                          textInputAction: TextInputAction.none,
                          onTapOutside: (_) {},
                          onSubmitted: (value) {
                            _debounce?.cancel();
                            context.read<ReadTerminalProductCubit>().searchProducts(value);
                            viewController.searchFocusNode.requestFocus();
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    focusNode: FocusNode(canRequestFocus: false),
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      context.read<ReadTerminalProductCubit>().searchProducts('');
                                      setState(() {});
                                    },
                                  )
                                : null,
                            hintText: "Buscar producto por nombre o código...",
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {});
                            _debounce?.cancel();
                            _debounce = Timer(
                              const Duration(milliseconds: 350),
                              () {
                                if (!mounted) return;
                                context.read<ReadTerminalProductCubit>().searchProducts(value);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 40,
                  child: Focus(
                    canRequestFocus: false,
                    descendantsAreFocusable: false,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _PriceLevelSelector(viewController: viewController),
                        const SizedBox(height: 8),
                        _UnitTypeSelector(viewController: viewController),
                      ],
                    ),
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

class _UnitTypeSelector extends StatelessWidget {
  const _UnitTypeSelector({required this.viewController});

  final SaleTerminalViewController viewController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewController,
      builder: (context, _) {
        return SizedBox(
          height: 44,
          child: Row(
            children: [
              const Text(
                "Unidad:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text("Detalle"),
                      icon: Icon(Icons.shopping_basket_outlined, size: 18),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text("Mayorista"),
                      icon: Icon(Icons.inventory_2_outlined, size: 18),
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
        );
      },
    );
  }
}

class _PriceLevelSelector extends StatelessWidget {
  const _PriceLevelSelector({required this.viewController});

  final SaleTerminalViewController viewController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewController,
      builder: (context, _) {
        return SizedBox(
          height: 44,
          child: Row(
            children: [
              const Text(
                "Nivel:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SegmentedButton<int>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: 1, label: Text("Nivel 1")),
                    ButtonSegment(value: 2, label: Text("Nivel 2")),
                    ButtonSegment(value: 3, label: Text("Nivel 3")),
                    ButtonSegment(value: 4, label: Text("Nivel 4")),
                  ],
                  selected: {viewController.selectedPriceLevel},
                  onSelectionChanged: (selection) {
                    viewController.selectedPriceLevel = selection.first;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
