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
  late TextEditingController _unitController;
  late TextEditingController _initialPriceController;
  late TextEditingController _initialCostController;
  late ProductType _selectedType;

  String tagField = "";

  ImageProvider? _currentImageProvider;
  Uint8List? _selectedImageBytes;
  bool _isImageDeleted = false;

  @override
  void initState() {
    super.initState();
    controller = WordChipTextController();
    _selectedType = widget.currentProduct?.productType ?? ProductType.item;
    widget.creationMap['productType'] = _selectedType.apiValue;
    _unitController = TextEditingController(
      text: widget.currentProduct?.unitName ?? (widget.creationMap['unitName'] as String? ?? ''),
    );
    _initialPriceController = TextEditingController();
    _initialCostController = TextEditingController();

    tagField = "";
    if (widget.currentProduct != null) {
      tagField = widget.currentProduct!.tags.join(" ");
      if (widget.currentProduct!.image.isNotEmpty) {
        _currentImageProvider = CachedNetworkImageProvider(
          widget.currentProduct!.image,
          cacheManager: AppImageCacheManager.instance,
          imageRenderMethodForWeb: ImageRenderMethodForWeb.HtmlImage,
        );
      }
    }

    Future(
      () {
        controller.text = tagField;
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _unitController.dispose();
    _initialPriceController.dispose();
    _initialCostController.dispose();
    super.dispose();
  }

  void _onTypeChanged(ProductType nextType) {
    setState(() {
      _selectedType = nextType;
      widget.creationMap['productType'] = nextType.apiValue;
      if (nextType == ProductType.service) {
        if (_unitController.text.trim().isEmpty) {
          _unitController.text = 'Servicio';
          widget.creationMap['unitName'] = 'Servicio';
        }
        widget.creationMap['extraUnits'] = const <ExtraUnit>[];
        widget.creationMap['defaultUnitIndex'] = 0;
        widget.creationMap['wholesaleUnitIndex'] = 0;
        widget.creationMap['priceUnitFactor'] = 1;
      }
    });
  }

  String _activeBranchId() {
    if (getIt.isRegistered<AuthCubit>()) {
      final auth = getIt<AuthCubit>();
      if (auth.state is Authenticated) {
        return auth.currentBranchId;
      }
    }
    return '';
  }

  String _activeBranchName() {
    if (getIt.isRegistered<AuthCubit>()) {
      final auth = getIt<AuthCubit>();
      if (auth.state is Authenticated) {
        return auth.currentBranchName;
      }
    }
    return 'Sucursal actual';
  }

  Future<void> _submitForm() async {
    widget.creationMap['unitName'] = _unitController.text.trim();
    widget.creationMap['productType'] = _selectedType.apiValue;
    if (!widget.formKey.currentState!.validate()) return;

    final activeBranchId = _activeBranchId();
    final activeBranchName = _activeBranchName();

    if (!_selectedType.tracksInventory &&
        (widget.currentProduct == null || widget.currentProduct!.tracksInventory) &&
        activeBranchId.isNotEmpty) {
      widget.creationMap['branchId'] = activeBranchId;
    }

    if (widget.currentProduct != null) {
      if (widget.currentProduct!.tracksInventory && !_selectedType.tracksInventory) {
        final confirmed = await DialogManager.confirmActionDialog(
          context,
          "Al convertir este artículo a ${_selectedType.label}, quedará asignado únicamente a la sucursal actual ($activeBranchName). "
          "Solo es posible si no tiene existencias ni stock comprometido en ninguna sucursal. "
          "Se conservan las facturas, el kárdex previo y los precios.\n\n¿Deseas continuar?",
        );
        if (confirmed != true || !mounted) return;
      } else if (!widget.currentProduct!.tracksInventory && _selectedType.tracksInventory) {
        final confirmed = await DialogManager.confirmActionDialog(
          context,
          "Al convertir este ${widget.currentProduct!.productType.label} a artículo, pasará al catálogo global de todas las sucursales y sus costos de referencia se reiniciarán.\n\n¿Deseas continuar?",
        );
        if (confirmed != true || !mounted) return;
      }
    }

    final writeCubit = context.read<WriteProductCubit>();

    try {
      String? imageUrl = widget.currentProduct?.image;

      if (_isImageDeleted) {
        imageUrl = "";
      }

      if (_selectedImageBytes != null) {
        LoadingDialogManager.showLoadingDialog(context);
        try {
          imageUrl = await ImageUploader.uploadImage(
            bytes: _selectedImageBytes!,
            fileName: "product_${DateTime.now().millisecondsSinceEpoch}.jpg",
          );
        } finally {
          if (mounted) {
            LoadingDialogManager.closeLoadingDialog(context);
          }
        }
      }

      if (!mounted) return;
      widget.creationMap['image'] = imageUrl ?? "";

      if (widget.currentProduct == null) {
        final createProduct = CreateProduct.fromJson(widget.creationMap);
        final priceDouble = double.tryParse(_initialPriceController.text.trim().replaceAll(',', '')) ?? 0.0;
        final costDouble = double.tryParse(_initialCostController.text.trim().replaceAll(',', '')) ?? 0.0;

        if (!_selectedType.tracksInventory && activeBranchId.isNotEmpty && (priceDouble > 0 || costDouble > 0)) {
          final data = CreateProductWithData(
            createProduct: createProduct,
            branchId: activeBranchId,
            inventoryInfo: InventoryInfo(
              quantity: 0,
              cost: NumberFormatter.convertFromDoubleToCents(costDouble),
              price: NumberFormatter.convertFromDoubleToCents(priceDouble),
            ),
          );
          writeCubit.createProductWithData(data);
        } else {
          writeCubit.createNewProduct(createProduct);
        }
      } else {
        final updateProduct = UpdateProduct.fromJson(widget.creationMap);
        writeCubit.updateProduct(widget.currentProduct!.id, updateProduct);
      }
    } catch (e) {
      if (mounted) {
        DialogManager.showErrorDialog(context, "Error al guardar imagen: $e");
      }
    }
  }

  void _onImageIntent(ImageSelectorIntent intent) {
    switch (intent) {
      case NewImageIntent():
        setState(() {
          _selectedImageBytes = intent.bytes;
          _currentImageProvider = MemoryImage(intent.bytes);
          _isImageDeleted = false;
        });
        break;
      case ChangeImageIntent():
        setState(() {
          _selectedImageBytes = intent.bytes;
          _currentImageProvider = MemoryImage(intent.bytes);
          _isImageDeleted = false;
        });
        break;
      case DeleteImageIntent():
        setState(() {
          _selectedImageBytes = null;
          _currentImageProvider = null;
          _isImageDeleted = true;
        });
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final unitsRepo = context.read<UnitsRepository>();
    final unitsMenuEntries = unitsRepo.units.map(
      (value) {
        return DropdownMenuEntry<String>(
          value: value.name,
          label: value.name,
        );
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
              controller: controller,
              unitController: _unitController,
              initialPriceController: _initialPriceController,
              initialCostController: _initialCostController,
              selectedType: _selectedType,
              onTypeChanged: _onTypeChanged,
              branchName: _activeBranchName(),
              imageProvider: _currentImageProvider,
              onImageIntent: _onImageIntent,
            ),

            const SizedBox(height: 24),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 16,
              children: [
                SizedBox(
                  height: 40,
                  child: PrimaryMenuButton(
                    onPressed: _submitForm,
                    label: Text("$wordPrefix Producto"),
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

    return SingleChildScrollView(
      child: Column(
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
              PrimaryMenuButton(
                onPressed: _submitForm,
                label: Text("$wordPrefix Producto"),
              ),
            ],
            content: _InnerContent(
              widget: widget,
              unitsMenuEntries: unitsMenuEntries,
              controller: controller,
              unitController: _unitController,
              initialPriceController: _initialPriceController,
              initialCostController: _initialCostController,
              selectedType: _selectedType,
              onTypeChanged: _onTypeChanged,
              branchName: _activeBranchName(),
              imageProvider: _currentImageProvider,
              onImageIntent: _onImageIntent,
            ),
          ),
        ],
      ),
    );
  }
}

class _InnerContent extends StatelessWidget {
  const _InnerContent({
    required this.widget,
    required this.unitsMenuEntries,
    required this.controller,
    required this.unitController,
    required this.initialPriceController,
    required this.initialCostController,
    required this.selectedType,
    required this.onTypeChanged,
    required this.branchName,
    required this.imageProvider,
    required this.onImageIntent,
  });

  final _FormContent widget;
  final Iterable<DropdownMenuEntry<String>> unitsMenuEntries;
  final WordChipTextController controller;
  final TextEditingController unitController;
  final TextEditingController initialPriceController;
  final TextEditingController initialCostController;
  final ProductType selectedType;
  final ValueChanged<ProductType> onTypeChanged;
  final String branchName;
  final ImageProvider? imageProvider;
  final void Function(ImageSelectorIntent intent) onImageIntent;

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
          Center(
            child: ImageSelectorWidget(
              image: imageProvider,
              width: 140,
              height: 140,
              placeholderText: selectedType.isService ? "Foto del servicio" : "Foto del producto",
              onIntent: onImageIntent,
            ),
          ),
          const SizedBox(height: 14),
          ProductTypeSelector(
            selectedType: selectedType,
            onChanged: onTypeChanged,
          ),
          if (!selectedType.tracksInventory) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: selectedType.isService ? Colors.deepPurple.shade50 : Colors.teal.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedType.isService ? Colors.deepPurple.shade200 : Colors.teal.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: selectedType.isService ? Colors.deepPurple.shade700 : Colors.teal.shade800,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedType.isService
                          ? "Servicio exclusivo de $branchName: siempre disponible para facturar sin control de stock ni kárdex."
                          : "Producto no inventariable de $branchName: se factura sin validar ni descontar existencias.",
                      style: TextStyle(
                        fontSize: 11.5,
                        color: selectedType.isService ? Colors.deepPurple.shade900 : Colors.teal.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          TitleTextField(
            key: const ValueKey("product_name"),
            title: selectedType.isService ? "Nombre del Servicio*" : "Nombre del Producto*",
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

          TitleTextField(
            key: const ValueKey("product_brand"),
            textCapitalization: TextCapitalization.words,
            initialValue: widget.currentProduct?.brandName,
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
            title: selectedType.tracksInventory ? "Marca*" : "Marca (Opcional)",
            validator: (value) {
              final trimmed = value?.trim() ?? '';
              if (selectedType.tracksInventory && trimmed.isEmpty) return "Campo requerido";
              widget.creationMap['brandName'] = trimmed;
              return null;
            },
          ),
          const SizedBox(height: 8),

          Row(
            children: [
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

              const SizedBox(width: 12),

              Flexible(
                child: TitleTextField(
                  key: const ValueKey("product_alt_code"),
                  tooltip: "Código alternativo o de barras secundario",
                  initialValue: widget.currentProduct?.altCode,
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  title: "Código Alternativo",
                  validator: (value) {
                    widget.creationMap['altCode'] = value?.trim() ?? "";
                    return null;
                  },
                ),
              ),
            ],
          ),
          if (!selectedType.isService) ...[
            const SizedBox(height: 12),
            ExtraUnitsSection(
              creationMap: widget.creationMap,
              currentProduct: widget.currentProduct,
              onPresetApplied: (preset) {
                unitController.text = preset.baseUnit;
                widget.creationMap['unitName'] = preset.baseUnit;
              },
            ),
          ],
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
                      controller: unitController,
                      initValue: currentUnit,
                      allowFreeText: true,
                      onChanged: (value) => widget.creationMap['unitName'] = value,
                      onClose: (value) => widget.creationMap['unitName'] = value.name,
                      onFieldSubmitted: (value) {
                        FocusScope.of(context).nextFocus();
                      },
                      validator: (value) {
                        final text = unitController.text.trim();
                        if (text.isEmpty) {
                          return "Campo requerido";
                        }
                        widget.creationMap['unitName'] = text;
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
                child: ProductCategorySelectorField(
                  initialCategoryName:
                      (widget.creationMap['categoryName'] as String?) ?? widget.currentProduct?.categoryName,
                  onChanged: (name) => widget.creationMap['categoryName'] = name ?? '',
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

          if (widget.currentProduct == null && !selectedType.tracksInventory) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sell_outlined, size: 17, color: Colors.blue.shade700),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Precio y Costo Inicial ($branchName)",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Flexible(
                        child: TitleTextField(
                          key: const ValueKey("service_initial_price"),
                          title: "Precio Venta (${NumberFormatter.currencySymbol})",
                          decoration: const InputDecoration(hintText: "0.00"),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [const DecimalTextInputFormatter()],
                          controller: initialPriceController,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: TitleTextField(
                          key: const ValueKey("service_initial_cost"),
                          title: "Costo Ref. (${NumberFormatter.currencySymbol})",
                          decoration: const InputDecoration(hintText: "0.00"),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [const DecimalTextInputFormatter()],
                          controller: initialCostController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

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
