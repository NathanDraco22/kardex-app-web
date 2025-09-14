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
          const SizedBox(height: 20),
          Row(
            children: [
              Flexible(
                fit: FlexFit.tight,
                child: _UnitFormField(
                  unitsMenuEntries: unitsMenuEntries,
                  creationMap: widget.creationMap,
                  initialSelection: widget.currentProduct?.unitName,
                ),
              ),

              const SizedBox(width: 12),

              Flexible(
                fit: FlexFit.tight,
                child: _CategoryFormField(
                  creationMap: widget.creationMap,
                  initialSelection: widget.currentProduct?.categoryName,
                  productCaterogriesEntries: productCaterogriesEntries,
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
        ],
      ),
    );
  }
}
