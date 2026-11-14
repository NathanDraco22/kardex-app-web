import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_business/kardex_business.dart';

class _FakeKardexConfig implements KardexClientConfig {
  _FakeKardexConfig({this.servinNickname, this.branchId});

  @override
  final String? servinNickname;

  @override
  final String? branchId;

  @override
  String get authToken => 'test-token';

  @override
  String get baseUrl => 'http://localhost:8000';

  @override
  String get practiceUrl => '';
}

void main() {
  test('generateTenantHeaders incluye tenant y sucursal', () {
    KardexClient.initialize(
      _FakeKardexConfig(servinNickname: 'tienda-a', branchId: 'branch-1'),
    );

    final headers = HttpTools.generateTenantHeaders();

    expect(headers['X-Agent'], 'Neptuno');
    expect(headers['X-Servin'], 'tienda-a');
    expect(headers['X-Branch'], 'branch-1');
  });

  test('generateTenantHeaders omite los headers nulos', () {
    KardexClient.initialize(_FakeKardexConfig());

    final headers = HttpTools.generateTenantHeaders();

    expect(headers.containsKey('X-Servin'), isFalse);
    expect(headers.containsKey('X-Branch'), isFalse);
  });

  test('generateAuthHeaders conserva Authorization y agrega tenant', () {
    KardexClient.initialize(
      _FakeKardexConfig(servinNickname: 'tienda-a', branchId: 'branch-1'),
    );

    final headers = HttpTools.generateAuthHeaders();

    expect(headers['Authorization'], 'Bearer test-token');
    expect(headers['X-Servin'], 'tienda-a');
    expect(headers['X-Branch'], 'branch-1');
  });
}
