import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  tearDown(() {
    BaseBranch.configureTaxIdLabelResolver(() => 'RUC');
  });

  group('BaseBranch.formattedRuc y taxIdLabel configurable', () {
    BaseBranch buildBranch(String idCard) => BaseBranch(
          name: 'Sucursal Central',
          idCard: idCard,
          address: 'Calle Principal',
          email: 'info@test.com',
          phone: '2222-0000',
        );

    test('retorna "RUC: <valor>" por defecto cuando idCard tiene contenido', () {
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

    test('usa la etiqueta configurada mediante configureTaxIdLabelResolver', () {
      BaseBranch.configureTaxIdLabelResolver(() => 'RTN');
      final branch = buildBranch('08011999123456');
      expect(branch.formattedRuc, 'RTN: 08011999123456');
      expect(branch.formattedTaxId(label: 'NIT'), 'NIT: 08011999123456');
    });
  });

  group('AppTaxIdLabel y AppSettingModel.taxIdLabel', () {
    test('tryFromLabel reconoce presets y retorna null para personalizados', () {
      expect(AppTaxIdLabel.tryFromLabel('rtn'), AppTaxIdLabel.rtn);
      expect(AppTaxIdLabel.tryFromLabel('Cédula Jurídica'), AppTaxIdLabel.cedulaJuridica);
      expect(AppTaxIdLabel.tryFromLabel('Tax ID'), isNull);
    });

    test('AppSettingModel.fromJson usa RUC como fallback retrocompatible', () {
      final legacy = AppSettingModel.fromJson(const {'id': 'Default', 'createdAt': 0});
      expect(legacy.taxIdLabel, 'RUC');

      final custom = AppSettingModel.fromJson(const {
        'id': 'Default',
        'createdAt': 0,
        'taxIdLabel': '  NIT  ',
      });
      expect(custom.taxIdLabel, 'NIT');
    });

    test('UpdateAppSetting serializa taxIdLabel recortado si no está vacío', () {
      expect(const UpdateAppSetting(taxIdLabel: '  RTN  ').toJson(), {'taxIdLabel': 'RTN'});
      expect(const UpdateAppSetting(taxIdLabel: '   ').toJson(), isEmpty);
    });
  });
}
