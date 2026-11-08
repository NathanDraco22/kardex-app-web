// Modelo mínimo para web. Evita que flutter_thermal_printer se compile en web.
// Debe exponer el subconjunto de la API de Printer que usa la aplicación.
// ignore_for_file: constant_identifier_names

class Printer {
  Printer({
    this.address,
    this.name,
    this.connectionType,
    this.isConnected,
    this.vendorId,
    this.productId,
  });

  factory Printer.fromJson(Map<String, dynamic> json) {
    return Printer(
      address: json['address'] as String?,
      name: json['name'] as String?,
      connectionType: _connectionTypeFromString(
        json['connectionType'] as String?,
      ),
      isConnected: json['isConnected'] as bool?,
      vendorId: json['vendorId']?.toString(),
      productId: json['productId']?.toString(),
    );
  }

  final String? address;
  final String? name;
  final ConnectionType? connectionType;
  final bool? isConnected;
  final String? vendorId;
  final String? productId;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'address': address,
      'name': name,
      'connectionType': connectionType?.name,
      'isConnected': isConnected,
      'vendorId': vendorId,
      'productId': productId,
    };
  }

  String get connectionTypeString {
    switch (connectionType) {
      case ConnectionType.BLE:
        return 'BLE';
      case ConnectionType.USB:
        return 'USB';
      case ConnectionType.NETWORK:
        return 'NETWORK';
      case null:
        return 'UNKNOWN';
    }
  }

  Printer copyWith({
    String? address,
    String? name,
    ConnectionType? connectionType,
    bool? isConnected,
    String? vendorId,
    String? productId,
  }) {
    return Printer(
      address: address ?? this.address,
      name: name ?? this.name,
      connectionType: connectionType ?? this.connectionType,
      isConnected: isConnected ?? this.isConnected,
      vendorId: vendorId ?? this.vendorId,
      productId: productId ?? this.productId,
    );
  }

  static ConnectionType? _connectionTypeFromString(String? type) {
    switch (type?.toUpperCase()) {
      case 'BLE':
        return ConnectionType.BLE;
      case 'USB':
        return ConnectionType.USB;
      case 'NETWORK':
        return ConnectionType.NETWORK;
      default:
        return null;
    }
  }
}

enum ConnectionType { BLE, USB, NETWORK }
