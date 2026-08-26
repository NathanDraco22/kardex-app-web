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
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Client selector bar
                TerminalClientBar(viewController: viewController, height: 36),
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
                        child: TerminalPriceLevelDropdown(
                          viewController: viewController,
                          height: 38,
                          fontSize: 13,
                          iconSize: 16,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Unit mode segmented button
                      Expanded(
                        flex: 50,
                        child: TerminalUnitTypeSelector(
                          viewController: viewController,
                          height: 38,
                          isCompact: true,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Search bar (at the bottom)
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
              ],
            );
          },
        ),
      ),
    );
  }
}
