import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  test('AdjustmentRequestItem parsea y serializa la imagen del producto', () {
    final item = AdjustmentRequestItem.fromJson({
      'productId': 'product-1',
      'productName': 'Producto de prueba',
      'image': 'https://example.com/producto.jpg',
    });

    expect(item.image, 'https://example.com/producto.jpg');
    expect(item.toJson()['image'], 'https://example.com/producto.jpg');
  });

  test('AdjustmentRequestItem usa image vacío cuando el backend no lo envía', () {
    final item = AdjustmentRequestItem.fromJson({
      'productId': 'product-1',
      'productName': 'Producto de prueba',
    });

    expect(item.image, isEmpty);
    expect(item.toJson()['image'], isEmpty);
  });
}
