import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:kardex_app_front/src/tools/uploaders/image_uploader.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/cubit/write_product_cubit.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/cubits/app_settings/app_settings_cubit.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

Future<ProductInDbInBranch?> showCreateProductWithDataDialog(
  BuildContext context, {
  String? branchId,
}) async {
  final productRepo = context.read<ProductsRepository>();
  final productCateRepo = context.read<ProductCategoriesRepository>();
  final unitRepo = context.read<UnitsRepository>();

  WriteProductCubit writeCubit;
  try {
    writeCubit = context.read<WriteProductCubit>();
  } catch (_) {
    writeCubit = WriteProductCubit(productRepo);
  }

  final widget = MultiRepositoryProvider(
    providers: [
      RepositoryProvider.value(value: productRepo),
      RepositoryProvider.value(value: productCateRepo),
      RepositoryProvider.value(value: unitRepo),
    ],
    child: BlocProvider.value(
      value: writeCubit,
      child: CreateProductWithDataDialog(branchId: branchId),
    ),
  );

  dynamic result;

  if (context.isMobile()) {
    result = await showModalBottomSheet(
      context: context,
      scrollControlDisabledMaxHeightRatio: 0.9,
      builder: (context) {
        return widget;
      },
    );
  } else {
    result = await showDialog(
      context: context,
      builder: (context) => widget,
    );
  }

  if (result is ProductInDbInBranch) {
    return result;
  }
  return null;
}

class CreateProductWithDataDialog extends StatefulWidget {
  const CreateProductWithDataDialog({super.key, this.branchId});

  final String? branchId;

  @override
  State<CreateProductWithDataDialog> createState() => _CreateProductWithDataDialogState();
}

class _CreateProductWithDataDialogState extends State<CreateProductWithDataDialog> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _creationMap = {};

  @override
  Widget build(BuildContext context) {
    _creationMap['isActive'] = true;
    _creationMap['hasIva'] = false;
    _creationMap['altCode'] = "";

    return BlocListener<WriteProductCubit, WriteProductState>(
      listener: (context, state) async {
        if (state is WriteProductInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteProductSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.pop(state.product);
        }

        if (state is WriteProductError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.error);
        }
      },
      child: Form(
        key: _formKey,
        child: _FormContent(
          formKey: _formKey,
          creationMap: _creationMap,
          branchId: widget.branchId,
        ),
      ),
    );
  }
}

class _FormContent extends StatefulWidget {
  const _FormContent({
    required this.formKey,
    required this.creationMap,
    this.branchId,
  });

  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> creationMap;
  final String? branchId;

  @override
  State<_FormContent> createState() => _FormContentState();
}

class _FormContentState extends State<_FormContent> {
  late _WordChipTextController _tagController;
  late TextEditingController _quantityController;
  late TextEditingController _costController;
  late TextEditingController _priceController;

  ImageProvider? _currentImageProvider;
  Uint8List? _selectedImageBytes;
  bool _isImageDeleted = false;

  @override
  void initState() {
    super.initState();
    _tagController = _WordChipTextController();
    _quantityController = TextEditingController(text: "0");
    _costController = TextEditingController(text: "0.00");
    _priceController = TextEditingController(text: "0.00");
  }

  @override
  void dispose() {
    _tagController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!widget.formKey.currentState!.validate()) return;

    final writeCubit = context.read<WriteProductCubit>();
    final authCubit = context.read<AuthCubit>();

    try {
      String imageUrl = "";

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

      widget.creationMap['image'] = imageUrl;

      final createProduct = CreateProduct.fromJson(widget.creationMap);

      final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
      final costDouble = double.tryParse(_costController.text.trim()) ?? 0.0;
      final priceDouble = double.tryParse(_priceController.text.trim()) ?? 0.0;

      final inventoryInfo = InventoryInfo(
        quantity: quantity,
        cost: NumberFormatter.convertFromDoubleToCents(costDouble),
        price: NumberFormatter.convertFromDoubleToCents(priceDouble),
      );

      final activeBranchId = widget.branchId ?? authCubit.currentBranchId;

      final createProductWithData = CreateProductWithData(
        createProduct: createProduct,
        branchId: activeBranchId,
        inventoryInfo: inventoryInfo,
      );

      writeCubit.createProductWithData(createProductWithData);
    } catch (e) {
      if (mounted) {
        DialogManager.showErrorDialog(context, "Error al procesar el producto: $e");
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
  Widget build(BuildContext context) {
    final unitsRepo = context.read<UnitsRepository>();
    final unitsMenuEntries = unitsRepo.units.map(
      (value) => DropdownMenuEntry<String>(
        value: value.name,
        label: value.name,
      ),
    );

    final productCateRepo = context.read<ProductCategoriesRepository>();
    final productCateEntries = productCateRepo.productCategories.map(
      (value) => DropdownMenuEntry<String>(
        value: value.name,
        label: value.name,
      ),
    );

    if (context.isMobile()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Nuevo Producto con Datos"),
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
              creationMap: widget.creationMap,
              branchId: widget.branchId,
              unitsMenuEntries: unitsMenuEntries,
              productCategoriesEntries: productCateEntries,
              tagController: _tagController,
              quantityController: _quantityController,
              costController: _costController,
              priceController: _priceController,
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
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text("Crear Producto"),
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
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
            title: const Text("Nuevo Producto con Datos"),
            actions: [
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Crear Producto"),
              ),
            ],
            content: _InnerContent(
              creationMap: widget.creationMap,
              branchId: widget.branchId,
              unitsMenuEntries: unitsMenuEntries,
              productCategoriesEntries: productCateEntries,
              tagController: _tagController,
              quantityController: _quantityController,
              costController: _costController,
              priceController: _priceController,
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
    required this.creationMap,
    this.branchId,
    required this.unitsMenuEntries,
    required this.productCategoriesEntries,
    required this.tagController,
    required this.quantityController,
    required this.costController,
    required this.priceController,
    required this.imageProvider,
    required this.onImageIntent,
  });

  final Map<String, dynamic> creationMap;
  final String? branchId;
  final Iterable<DropdownMenuEntry<String>> unitsMenuEntries;
  final Iterable<DropdownMenuEntry<String>> productCategoriesEntries;
  final _WordChipTextController tagController;
  final TextEditingController quantityController;
  final TextEditingController costController;
  final TextEditingController priceController;
  final ImageProvider? imageProvider;
  final void Function(ImageSelectorIntent intent) onImageIntent;

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    final branchName = authCubit.currentBranchName;

    return SizedBox(
      width: 350,
      child: Column(
        children: [
          Center(
            child: ImageSelectorWidget(
              image: imageProvider,
              width: 140,
              height: 140,
              placeholderText: "Foto del producto",
              onIntent: onImageIntent,
            ),
          ),
          const SizedBox(height: 16),
          TitleTextField(
            key: const ValueKey("product_name"),
            title: "Nombre del Producto*",
            textCapitalization: TextCapitalization.words,
            autofocus: true,
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return "Campo requerido";
              creationMap['name'] = value.trim();
              return null;
            },
          ),
          const SizedBox(height: 8),
          TitleTextField(
            key: const ValueKey("product_brand"),
            textCapitalization: TextCapitalization.words,
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
            title: "Marca*",
            validator: (value) {
              if (value == null || value.trim().isEmpty) return "Campo requerido";
              creationMap['brandName'] = value.trim();
              return null;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Flexible(
                child: TitleTextField(
                  key: const ValueKey("product_code"),
                  tooltip: "El código es autogenerado si se deja vacío",
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  title: "Código",
                  validator: (value) {
                    if (value == null) return null;
                    creationMap['code'] = value.trim();
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: TitleTextField(
                  key: const ValueKey("product_alt_code"),
                  tooltip: "Código alternativo o de barras secundario",
                  onEditingComplete: () => FocusScope.of(context).nextFocus(),
                  title: "Código Alternativo",
                  validator: (value) {
                    creationMap['altCode'] = value?.trim() ?? "";
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
                      onClose: (value) => creationMap['unitName'] = value.name,
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
                              creationMap['unitName'] = value[index].name;
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
                      "Categoría",
                      textAlign: TextAlign.start,
                    ),
                    const SizedBox(height: 6),
                    CustomAutocompleteTextfield<ProductCategoryInDb>(
                      readOnly: false,
                      onClose: (value) => creationMap['categoryName'] = value.name,
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
                              creationMap['categoryName'] = value[index].name;
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
            controller: tagController,
            title: "Palabras Claves",
            maxLines: 2,
            onEditingComplete: () => FocusScope.of(context).nextFocus(),
            validator: (value) {
              if (value == null) return null;
              final tags = value.split(" ").map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
              creationMap['tags'] = tags;
              return null;
            },
          ),
          const SizedBox(height: 16),
          _ExtraUnitsSection(creationMap: creationMap),
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
                    Icon(Icons.inventory_2_outlined, size: 18, color: Colors.blue.shade700),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Inventario y Precio Inicial ($branchName)",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TitleTextField(
                  key: const ValueKey("initial_quantity"),
                  title: "Cantidad Inicial*",
                  keyboardType: TextInputType.number,
                  inputFormatters: [IntegerTextInputFormatter()],
                  controller: quantityController,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return "Campo requerido";
                    final n = int.tryParse(val.trim());
                    if (n == null || n < 0) return "Debe ser un número >= 0";
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Flexible(
                      child: TitleTextField(
                        key: const ValueKey("initial_cost"),
                        title: "Costo Unitario ($defaultCoinSymbol)*",
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [DecimalTextInputFormatter()],
                        controller: costController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return "Requerido";
                          final d = double.tryParse(val.trim());
                          if (d == null || d < 0) return ">= 0";
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: TitleTextField(
                        key: const ValueKey("initial_price"),
                        title: "Precio Venta ($defaultCoinSymbol)*",
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [DecimalTextInputFormatter()],
                        controller: priceController,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return "Requerido";
                          final d = double.tryParse(val.trim());
                          if (d == null || d < 0) return ">= 0";
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                AnimatedBuilder(
                  animation: costController,
                  builder: (context, _) {
                    final appSettings = getIt<AppSettingsCubit>();
                    if (!appSettings.useDefaultProfitMargin) {
                      return const SizedBox.shrink();
                    }
                    final profitMargin = appSettings.defaultProfitMargin;
                    final costVal = double.tryParse(costController.text.trim().replaceAll(',', '')) ?? 0.0;
                    if (costVal <= 0) {
                      return const SizedBox.shrink();
                    }
                    final suggestedPrice = costVal * (1 + profitMargin / 100);

                    return Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 18, color: Colors.blue.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Precio Sugerido (+${profitMargin.toStringAsFixed(profitMargin.truncateToDouble() == profitMargin ? 0 : 1)}%): $defaultCoinSymbol ${suggestedPrice.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                                Text(
                                  "Calculado sobre costo ($defaultCoinSymbol ${costVal.toStringAsFixed(2)})",
                                  style: TextStyle(fontSize: 11, color: Colors.blue.shade700),
                                ),
                              ],
                            ),
                          ),
                          FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              textStyle: const TextStyle(color: Colors.white),
                            ),
                            onPressed: () {
                              priceController.text = suggestedPrice.toStringAsFixed(2);
                            },
                            child: const Text("Usar Precio Sugerido", style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          StatefulBuilder(
            builder: (context, setState) {
              return SwitchListTile(
                value: creationMap['hasIva'] ?? false,
                tileColor: Colors.grey.shade100,
                title: const Text("IVA"),
                onChanged: (value) {
                  creationMap['hasIva'] = value;
                  setState(() {});
                },
              );
            },
          ),
          StatefulBuilder(
            builder: (context, setState) {
              return SwitchListTile(
                value: creationMap['isActive'] ?? true,
                tileColor: Colors.grey.shade100,
                title: const Text("Activo"),
                onChanged: (value) {
                  creationMap['isActive'] = value;
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

class _ExtraUnitsSection extends StatefulWidget {
  const _ExtraUnitsSection({required this.creationMap});

  final Map<String, dynamic> creationMap;

  @override
  State<_ExtraUnitsSection> createState() => _ExtraUnitsSectionState();
}

class _ExtraUnitsSectionState extends State<_ExtraUnitsSection> {
  final List<ExtraUnit> _extraUnits = [];
  int _defaultUnitIndex = 0;
  int _wholesaleUnitIndex = 0;

  @override
  void initState() {
    super.initState();
    _syncToMap();
  }

  void _syncToMap() {
    widget.creationMap['extraUnits'] = _extraUnits.map((e) => e.toJson()).toList();
    if (_defaultUnitIndex > _extraUnits.length) {
      _defaultUnitIndex = 0;
    }
    widget.creationMap['defaultUnitIndex'] = _defaultUnitIndex;

    if (_wholesaleUnitIndex > _extraUnits.length) {
      _wholesaleUnitIndex = 0;
    }
    widget.creationMap['wholesaleUnitIndex'] = _wholesaleUnitIndex;
  }

  @override
  Widget build(BuildContext context) {
    final String baseUnitName = widget.creationMap['unitName'] as String? ?? 'Unidad Base';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () async {
                final result = await showProductExtraUnitsEditor(
                  context,
                  initialExtraUnits: _extraUnits,
                  initialDefaultUnitIndex: _defaultUnitIndex,
                  initialWholesaleUnitIndex: _wholesaleUnitIndex,
                  baseUnitName: baseUnitName,
                );

                if (result != null) {
                  setState(() {
                    _extraUnits.clear();
                    _extraUnits.addAll(result.extraUnits);
                    _defaultUnitIndex = result.defaultUnitIndex;
                    _wholesaleUnitIndex = result.wholesaleUnitIndex;
                    _syncToMap();
                  });
                }
              },
              icon: const Icon(Icons.scale),
              label: Text("Unidades de Medida Extra (${_extraUnits.length})"),
            ),
          ],
        ),
      ],
    );
  }
}

class _WordChipTextController extends TextEditingController {
  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final List<TextSpan> children = [];
    final regex = RegExp(r"(\S+\s)");

    final chipStyle = TextStyle(
      backgroundColor: Colors.green.withValues(alpha: 0.4),
      color: Colors.green.shade900,
      fontWeight: FontWeight.bold,
    );

    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final wordWithSpace = match.group(0)!;
        final word = wordWithSpace.trim();

        children.add(
          TextSpan(text: word, style: chipStyle),
        );

        children.add(
          TextSpan(text: ' ', style: style),
        );

        return '';
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return '';
      },
    );

    return TextSpan(style: style, children: children);
  }
}
