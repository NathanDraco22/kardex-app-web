import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  group('BaseBranch.formattedRuc', () {
    BaseBranch buildBranch(String idCard) => BaseBranch(
          name: 'Sucursal Central',
          idCard: idCard,
          address: 'Calle Principal',
          email: 'info@test.com',
          phone: '2222-0000',
        );

    test('retorna "RUC: <valor>" cuando idCard tiene contenido', () {
      final branch = buildBranch('J0310000123456');
      expect(branch.formattedRuc, 'RUC: J0310000123456');
    });

    test('recorta espacios en blanco alrededor de idCard', () {
      final branch = buildBranch('  J0310000123456  ');
      expect(branch.formattedRuc, 'RUC: J0310000123456');
    });

    test('retorna null cuando idCard está vacío o solo tiene espacios', () {
      expect(buildBranch('').formattedRuc, isNull);
      expect(buildBranch('   ').formattedRuc, isNull);
    });
  });
}
