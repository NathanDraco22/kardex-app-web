import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/input_formatters.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';
import 'package:kardex_business/kardex_business.dart';

import 'price_level_sync_controller.dart';

/// Un nivel de precio con su campo en unidad base y, si hay una unidad extra
/// seleccionada, su equivalente por esa unidad.
class PriceLevelField extends StatelessWidget {
  const PriceLevelField({
    super.key,
    required this.levelKey,
    required this.title,
    required this.baseFocusNode,
    required this.baseController,
    required this.onBaseChanged,
    this.extraFocusNode,
    this.extraController,
    this.onExtraChanged,
    this.extraUnitName,
  });

  final String levelKey;
  final String title;
  final FocusNode baseFocusNode;
  final TextEditingController baseController;
  final ValueChanged<String> onBaseChanged;

  final FocusNode? extraFocusNode;
  final TextEditingController? extraController;
  final ValueChanged<String>? onExtraChanged;
  final String? extraUnitName;

  @override
  Widget build(BuildContext context) {
    final baseInput = TitleTextField(
      key: Key(levelKey),
      title: title,
      focusNode: baseFocusNode,
      keyboardType: TextInputType.number,
      controller: baseController,
      onChanged: onBaseChanged,
      textInputAction: TextInputAction.next,
      inputFormatters: [DoubleThousandsFormatter()],
    );

    if (extraController == null || extraUnitName == null) {
      return baseInput;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: baseInput),
        const SizedBox(width: 16),
        Expanded(
          child: TitleTextField(
            key: Key('${levelKey}_extra'),
            title: 'Por $extraUnitName (${NumberFormatter.currencySymbol}):',
            focusNode: extraFocusNode,
            keyboardType: TextInputType.number,
            controller: extraController,
            onChanged: onExtraChanged,
            textInputAction: TextInputAction.next,
            inputFormatters: [DoubleThousandsFormatter()],
          ),
        ),
      ],
    );
  }
}

/// Sección con todos los niveles de precio del editor.
class PriceLevelsSection extends StatelessWidget {
  const PriceLevelsSection({
    super.key,
    required this.controller,
    required this.onChanged,
    this.titles,
    this.spacing = 12,
  });

  final PriceLevelSyncController controller;
  final VoidCallback onChanged;

  /// Títulos por nivel. Si se omite, se generan como "Precio de Venta",
  /// "Precio de Venta 2", etc. usando el símbolo de moneda configurado.
  final List<String>? titles;

  final double spacing;

  @override
  Widget build(BuildContext context) {
    final extraUnit = controller.selectedUnit;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < controller.levelCount; index++) ...[
          if (index > 0) SizedBox(height: spacing),
          PriceLevelField(
            levelKey: 'price${index + 1}',
            title: _titleFor(index),
            baseFocusNode: controller.baseFocusNodes[index],
            baseController: controller.baseControllers[index],
            onBaseChanged: (value) {
              controller.onBaseChanged(index, value);
              onChanged();
            },
            extraFocusNode: controller.extraFocusNodes[index],
            extraController: extraUnit == null ? null : controller.extraControllers[index],
            extraUnitName: extraUnit?.name,
            onExtraChanged: (value) {
              controller.onExtraChanged(index, value);
              onChanged();
            },
          ),
        ],
      ],
    );
  }

  String _titleFor(int index) {
    if (titles != null && index < titles!.length) {
      return titles![index];
    }

    final suffix = index == 0 ? '' : ' ${index + 1}';
    return 'Precio de Venta$suffix (${NumberFormatter.currencySymbol})';
  }
}
