import 'package:kardex_business/kardex_business.dart';

class ImportTemplate {
  const ImportTemplate({
    required this.fileName,
    required this.content,
    required this.columns,
  });

  final String fileName;
  final String content;
  final List<String> columns;
}

class ImportTemplates {
  ImportTemplates._();

  static const _productColumns = [
    "name",
    "description",
    "code",
    "brandName",
    "unitName",
    "categoryName",
    "tags",
    "hasIva",
    "isActive",
    "quantity",
    "cost",
    "price",
    "price2",
    "price3",
    "price4",
  ];

  static const _clientColumns = [
    "name",
    "cardId",
    "phone",
    "address",
    "location",
    "email",
    "group",
    "creditLimit",
    "initialBalance",
  ];

  static const _supplierColumns = [
    "name",
    "cardId",
    "email",
    "phone",
  ];

  static ImportTemplate forType(ImportType type) {
    return switch (type) {
      ImportType.initialInventory => _productTemplate(
        fileName: "plantilla_inventario_inicial.csv",
      ),
      ImportType.inventory => _productTemplate(
        fileName: "plantilla_inventario.csv",
      ),
      ImportType.clients => ImportTemplate(
        fileName: "plantilla_clientes.csv",
        content: "${_clientColumns.join(",")}\n",
        columns: _clientColumns,
      ),
      ImportType.suppliers => ImportTemplate(
        fileName: "plantilla_proveedores.csv",
        content: "${_supplierColumns.join(",")}\n",
        columns: _supplierColumns,
      ),
    };
  }

  static ImportTemplate _productTemplate({required String fileName}) {
    return ImportTemplate(
      fileName: fileName,
      content: "${_productColumns.join(",")}\n",
      columns: _productColumns,
    );
  }
}
