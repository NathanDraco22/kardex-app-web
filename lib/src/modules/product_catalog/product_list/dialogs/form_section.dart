part of 'create_product_dialog.dart';

class _FormContent extends StatefulWidget {
  const _FormContent({
    required this.formKey,
    required this.creationMap,
    required this.currentProduct,
  });

  final GlobalKey<FormState> formKey;
  final Map creationMap;
  final ProductInDb? currentProduct;

  @override
  State<_FormContent> createState() => _FormContentState();
}

class _FormContentState extends State<_FormContent> {
  late WordChipTextController controller;

  String tagField = "";

  @override
  void initState() {
    super.initState();
    controller = WordChipTextController();

    tagField = "";
    if (widget.currentProduct != null) {
      tagField = widget.currentProduct!.tags.join(" ");
    }

    Future(
      () {
        controller.text = tagField;
      },
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final writeCubit = context.read<WriteProductCubit>();

    final unitsRepo = context.read<UnitsRepository>();
    final unitsMenuEntries = unitsRepo.units.map(
      (value) {
        return DropdownMenuEntry<String>(
          value: value.name,
          label: value.name,
        );
      },
    );

    final productCaterogriesRepo = context.read<ProductCategoriesRepository>();
    final productCaterogriesEntries = productCaterogriesRepo.productCategories.map(
      (value) {
        return DropdownMenuEntry<String>(value: value.name, label: value.name);
      },
    );

    final wordPrefix = widget.currentProduct == null ? "Agregar" : "Actualizar";

    if (context.isMobile()) {
      return Scaffold(
        appBar: AppBar(
          title: Text("$wordPrefix Producto"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.0,
        ),
        backgroundColor: Colors.white,
        body: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(16),
          children: [
            _InnerContent(
              widget: widget,
              unitsMenuEntries: unitsMenuEntries,
              productCaterogriesEntries: productCaterogriesEntries,
              controller: controller,
            ),

            const SizedBox(height: 24),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!widget.formKey.currentState!.validate()) return;

                      if (widget.currentProduct == null) {
                        final createProduct = CreateProduct.fromJson(widget.creationMap);
                        writeCubit.createNewProduct(createProduct);
                      } else {
                        final updateClient = UpdateProduct.fromJson(widget.creationMap);
                        writeCubit.updateProduct(widget.currentProduct!.id, updateClient);
                      }
                    },
                    child: Text("$wordPrefix Producto"),
                  ),
                ),

                SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {
                      context.pop();
                    },
                    child: const Text("Cancelar"),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AlertDialog(
          constraints: const BoxConstraints(minWidth: 600),
          insetPadding: EdgeInsets.zero,
          title: Text("$wordPrefix Producto"),
          actions: [
            OutlinedButton(
              onPressed: () {
                context.pop();
              },
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                if (!widget.formKey.currentState!.validate()) return;

                if (widget.currentProduct == null) {
                  final createProduct = CreateProduct.fromJson(widget.creationMap);
                  writeCubit.createNewProduct(createProduct);
                } else {
                  final updateClient = UpdateProduct.fromJson(widget.creationMap);
                  writeCubit.updateProduct(widget.currentProduct!.id, updateClient);
                }
              },
              child: Text("$wordPrefix Producto"),
            ),
          ],
          content: _InnerContent(
            widget: widget,
            unitsMenuEntries: unitsMenuEntries,
            productCaterogriesEntries: productCaterogriesEntries,
            controller: controller,
          ),
        ),
      ],
    );
  }
}

class _InnerContent extends StatelessWidget {
  const _InnerContent({
    required this.widget,
    required this.unitsMenuEntries,
    required this.productCaterogriesEntries,
    required this.controller,
  });

  final _FormContent widget;
  final Iterable<DropdownMenuEntry<String>> unitsMenuEntries;
  final Iterable<DropdownMenuEntry<String>> productCaterogriesEntries;
  final WordChipTextController controller;

  @override
  Widget build(BuildContext context) {
    final unitsRepo = context.read<UnitsRepository>();
    UnitInDb? currentUnit;
    for (var element in unitsRepo.units) {
      if (element.name == widget.currentProduct?.unitName) {
        currentUnit = element;
        break;
      }
    }
    return SizedBox(
      width: 350,
      child: Column(
        children: [
          TitleTextField(
            key: const ValueKey("product_name"),
            title: "Nombre del Producto*",
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
            initialValue: widget.currentProduct?.name,
            validator: (value) {
              if (value == null || value.isEmpty) return "Campo requerido";
              widget.creationMap['name'] = value.trim();
              return null;
            },
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Flexible(
                child: TitleTextField(
                  key: const ValueKey("product_brand"),
                  textCapitalization: TextCapitalization.words,
                  initialValue: widget.currentProduct?.brandName,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  title: "Marca*",
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Campo requerido";
                    widget.creationMap['brandName'] = value.trim();
                    return null;
                  },
                ),
              ),

              const SizedBox(width: 12),

              Flexible(
                child: TitleTextField(
                  key: const ValueKey("product_code"),
                  tooltip: "El codigo es autogenerado si se deja vacio",
                  initialValue: widget.currentProduct?.code,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  title: "Codigo",
                  validator: (value) {
                    if (value == null) {
                      return null;
                    }
                    widget.creationMap['code'] = value.trim();
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Unidad de Medida*",
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 6),
                    CustomAutocompleteTextfield<UnitInDb>(
                      initValue: currentUnit,
                      onClose: (value) => widget.creationMap['unitName'] = value.name,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).nextFocus();
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Campo requerido";
                        }
                        return null;
                      },
                      onSearch: (value) {
                        final repo = context.read<UnitsRepository>();
                        return repo.searchUnitByKeywordLocal(value);
                      },
                      suggestionBuilder: (value, close) {
                        return ListView.builder(
                          itemCount: value.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) => ListTile(
                            title: Text(value[index].name),
                            onTap: () {
                              widget.creationMap['unitName'] = value[index].name;
                              close(value[index]);
                              FocusScope.of(context).nextFocus();
                            },
                          ),
                        );
                      },
                      titleBuilder: (value) => value.name,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Categoria",
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 6),
                    CustomAutocompleteTextfield<ProductCategoryInDb>(
                      readOnly: false,
                      onClose: (value) => widget.creationMap['categoryName'] = value.name,
                      onSearch: (value) {
                        final repo = context.read<ProductCategoriesRepository>();
                        return repo.searchProductCategoryByKeywordLocal(value);
                      },
                      suggestionBuilder: (value, close) {
                        return ListView.builder(
                          itemCount: value.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) => ListTile(
                            title: Text(value[index].name),
                            onTap: () {
                              widget.creationMap['categoryName'] = value[index].name;
                              close(value[index]);
                              FocusScope.of(context).nextFocus();
                            },
                          ),
                        );
                      },
                      titleBuilder: (value) => value.name,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          TitleTextField(
            key: const ValueKey("product_tags"),
            controller: controller,
            title: "Palabras Claves",
            maxLines: 2,
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
            validator: (value) {
              if (value == null) {
                return null;
              }
              final tags = value.split(" ").map((e) => e.trim()).toList();
              if (tags.isEmpty) {
                widget.creationMap['tags'] = [];
                return null;
              }
              widget.creationMap['tags'] = tags;
              return null;
            },
          ),

          const SizedBox(height: 16),
          StatefulBuilder(
            builder: (context, setState) {
              return SwitchListTile(
                value: widget.creationMap['hasIva'] ?? false,
                tileColor: Colors.grey.shade100,
                title: const Text("IVA"),
                onChanged: (value) {
                  widget.creationMap['hasIva'] = value;
                  setState(() {});
                },
              );
            },
          ),

          StatefulBuilder(
            builder: (context, setState) {
              return SwitchListTile(
                value: widget.creationMap['isActive'] ?? true,
                tileColor: Colors.grey.shade100,
                title: const Text("Activo"),
                onChanged: (value) {
                  widget.creationMap['isActive'] = value;
                  setState(() {});
                },
              );
            },
          ),

          const SizedBox(height: 16),

          if (widget.currentProduct != null)
            ListTile(
              title: const Text("Borrar Producto", style: TextStyle(color: Colors.red)),
              leading: const Icon(Icons.delete, color: Colors.red),
              onTap: () async {
                final isConfirmed = await DialogManager.slideToConfirmDeleteActionDialog(
                  context,
                  "¿Estas seguro de borrar el producto ${widget.currentProduct?.name}?"
                  "El producto se borrara permanentemente",
                );

                if (!isConfirmed) return;
                if (!context.mounted) return;
                if (widget.currentProduct == null) return;
                context.read<WriteProductCubit>().deleteProduct(widget.currentProduct!.id);
              },
              tileColor: Colors.red.shade100,
            ),
        ],
      ),
    );
  }
}
