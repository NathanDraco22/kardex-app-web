import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  test('AppSettingModel parsea y serializa companyLogoUrl', () {
    final model = AppSettingModel.fromJson({
      'id': 'Default',
      'companyLogoUrl': 'https://example.com/company-logo.png',
      'createdAt': 0,
    });

    expect(model.companyLogoUrl, 'https://example.com/company-logo.png');
    expect(
      model.toJson()['companyLogoUrl'],
      'https://example.com/company-logo.png',
    );
  });

  test('UpdateAppSetting incluye companyLogoUrl solo cuando se define', () {
    expect(
      const UpdateAppSetting().toJson().containsKey('companyLogoUrl'),
      isFalse,
    );

    expect(
      const UpdateAppSetting(
        companyLogoUrl: 'https://example.com/company-logo.png',
      ).toJson()['companyLogoUrl'],
      'https://example.com/company-logo.png',
    );

    expect(
      const UpdateAppSetting(companyLogoUrl: "").toJson()['companyLogoUrl'],
      "",
    );
  });
}
