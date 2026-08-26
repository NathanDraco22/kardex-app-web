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
        padding: const EdgeInsets.all(8),
        child: ListenableBuilder(
          listenable: viewController,
          builder: (context, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top control area: Left = Client Card (height of 2 rows), Right = Unit mode (row 1) & Price level (row 2)
                Focus(
                  canRequestFocus: false,
                  descendantsAreFocusable: false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Client Card occupying 2 rows height
                      Expanded(
                        child: TerminalDesktopClientCard(viewController: viewController),
                      ),
                      const SizedBox(width: 8),
                      // Right: 2 rows (Row 1 = Wholesale/Retail, Row 2 = Price Level)
                      SizedBox(
                        width: 290,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TerminalUnitTypeSelector(viewController: viewController),
                            const SizedBox(height: 6),
                            TerminalPriceLevelDropdown(viewController: viewController),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Search bar
                SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _searchController,
                    focusNode: viewController.searchFocusNode,
                    autofocus: true,
                    textInputAction: TextInputAction.none,
                    onTapOutside: (_) {},
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
                      isDense: true,
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              focusNode: FocusNode(canRequestFocus: false),
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                context.read<ReadTerminalProductCubit>().searchProducts('');
                                setState(() {});
                              },
                            )
                          : null,
                      hintText: "Buscar producto por nombre o código...",
                      hintStyle: const TextStyle(fontSize: 13),
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
              ],
            );
          },
        ),
      ),
    );
  }
}
