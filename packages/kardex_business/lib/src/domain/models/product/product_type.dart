enum ProductType {
  item('item', 'Artículo'),
  nonInventory('nonInventory', 'No inventariable'),
  service('service', 'Servicio');

  const ProductType(this.apiValue, this.label);

  final String apiValue;
  final String label;

  bool get tracksInventory => this == ProductType.item;
  bool get isService => this == ProductType.service;

  static ProductType fromJson(dynamic value) {
    if (value is ProductType) return value;
    final raw = value?.toString();
    for (final type in ProductType.values) {
      if (type.apiValue == raw) return type;
    }
    return ProductType.item;
  }
}
