import 'package:material_ui/material_ui.dart';

typedef ClientPriceLevelChanged =
    void Function({
      required bool usePreferredPrice,
      required int defaultPriceLevel,
    });

enum _ClientPriceLevelOption {
  none(
    label: 'Sin Preferencia',
    usePreferredPrice: false,
    defaultPriceLevel: 1,
  ),
  price1(label: 'Precio 1', usePreferredPrice: true, defaultPriceLevel: 1),
  price2(label: 'Precio 2', usePreferredPrice: true, defaultPriceLevel: 2),
  price3(label: 'Precio 3', usePreferredPrice: true, defaultPriceLevel: 3),
  price4(label: 'Precio 4', usePreferredPrice: true, defaultPriceLevel: 4);

  const _ClientPriceLevelOption({
    required this.label,
    required this.usePreferredPrice,
    required this.defaultPriceLevel,
  });

  final String label;
  final bool usePreferredPrice;
  final int defaultPriceLevel;
}

/// Selector compartido de precio preferencial de un cliente.
///
/// "Sin Preferencia" se representa como `usePreferredPrice = false` y
/// `defaultPriceLevel = 1`; "Precio N" como `usePreferredPrice = true` y
/// `defaultPriceLevel = N`. El widget no decide si debe mostrarse; esa decisión
/// la toma el formulario con `AppSettingsPolicy.useClientPreferredPrices`.
class ClientPriceLevelDropdown extends StatelessWidget {
  const ClientPriceLevelDropdown({
    super.key,
    required this.usePreferredPrice,
    required this.defaultPriceLevel,
    required this.onChanged,
  });

  final bool usePreferredPrice;
  final int defaultPriceLevel;
  final ClientPriceLevelChanged onChanged;

  _ClientPriceLevelOption get _selectedOption {
    if (!usePreferredPrice) return _ClientPriceLevelOption.none;
    for (final option in _ClientPriceLevelOption.values) {
      if (option.usePreferredPrice && option.defaultPriceLevel == defaultPriceLevel) {
        return option;
      }
    }
    return _ClientPriceLevelOption.none;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<_ClientPriceLevelOption>(
      decoration: const InputDecoration(
        labelText: 'Nivel de precio predeterminado',
        border: OutlineInputBorder(),
      ),
      initialValue: _selectedOption,
      items: _ClientPriceLevelOption.values
          .map(
            (option) => DropdownMenuItem(
              value: option,
              child: Text(option.label),
            ),
          )
          .toList(),
      onChanged: (selected) {
        if (selected == null) return;
        onChanged(
          usePreferredPrice: selected.usePreferredPrice,
          defaultPriceLevel: selected.defaultPriceLevel,
        );
      },
    );
  }
}
