import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_business/kardex_business.dart';

ClientInDb _client(int level, {bool usePreferredPrice = true}) {
  return ClientInDb(
    id: 'client-1',
    name: 'Cliente de prueba',
    createdAt: DateTime(2026, 11, 28),
    usePreferredPrice: usePreferredPrice,
    defaultPriceLevel: level,
  );
}

void main() {
  group('ClientPricePreferencePolicy', () {
    test('sin preferencia cuando la función global está apagada', () {
      final policy = ClientPricePreferencePolicy(
        client: _client(2),
        enabled: false,
      );

      expect(policy.preferredPriceLevel, isNull);
      expect(policy.hasPreference, isFalse);
    });

    test('sin preferencia cuando no hay cliente', () {
      const policy = ClientPricePreferencePolicy(
        client: null,
        enabled: true,
      );

      expect(policy.preferredPriceLevel, isNull);
      expect(policy.hasPreference, isFalse);
    });

    test('sin preferencia cuando el cliente tiene usePreferredPrice false', () {
      final policy = ClientPricePreferencePolicy(
        client: _client(1, usePreferredPrice: false),
        enabled: true,
      );

      expect(policy.preferredPriceLevel, isNull);
      expect(policy.hasPreference, isFalse);
    });

    test('sin preferencia con nivel 0', () {
      final policy = ClientPricePreferencePolicy(
        client: _client(0),
        enabled: true,
      );

      expect(policy.preferredPriceLevel, isNull);
      expect(policy.hasPreference, isFalse);
    });

    test('sin preferencia con valores fuera de 1..4', () {
      for (final level in [5, -2, 10, -100]) {
        final policy = ClientPricePreferencePolicy(
          client: _client(level),
          enabled: true,
        );

        expect(
          policy.preferredPriceLevel,
          isNull,
          reason: 'nivel $level debe significar Sin Preferencia',
        );
        expect(policy.hasPreference, isFalse);
      }
    });

    test('devuelve el nivel cuando usePreferredPrice y el nivel son válidos', () {
      for (final level in [1, 2, 3, 4]) {
        final policy = ClientPricePreferencePolicy(
          client: _client(level),
          enabled: true,
        );

        expect(policy.preferredPriceLevel, level);
        expect(policy.hasPreference, isTrue);
      }
    });

    test('la policy de AppSettings aplica la bandera global', () {
      const enabled = AppSettingsPolicy(
        AppSettingModel(
          id: 'test',
          createdAt: 0,
          useClientPreferredPrices: true,
        ),
      );
      const disabled = AppSettingsPolicy(
        AppSettingModel(
          id: 'test',
          createdAt: 0,
          useClientPreferredPrices: false,
        ),
      );

      expect(
        enabled.clientPricePreferenceFor(_client(3)).preferredPriceLevel,
        3,
      );
      expect(
        disabled.clientPricePreferenceFor(_client(3)).preferredPriceLevel,
        isNull,
      );
      expect(
        enabled.clientPricePreferenceFor(_client(1, usePreferredPrice: false)).preferredPriceLevel,
        isNull,
      );
    });

    test('normalize fuerza Sin Preferencia cuando el nivel es inválido', () {
      final cases = <(bool, int, bool, int)>[
        (true, 5, false, 1),
        (false, 5, false, 1),
        (true, 3, true, 3),
        (false, 1, false, 1),
        (true, 0, false, 1),
        (true, 1, true, 1),
        (true, 4, true, 4),
      ];

      for (final (use, level, expectedUse, expectedLevel) in cases) {
        final result = ClientPricePreferencePolicy.normalize(
          usePreferredPrice: use,
          defaultPriceLevel: level,
        );

        expect(
          result.usePreferredPrice,
          expectedUse,
          reason: 'usePreferredPrice para ($use, $level)',
        );
        expect(
          result.defaultPriceLevel,
          expectedLevel,
          reason: 'defaultPriceLevel para ($use, $level)',
        );
      }
    });
  });

  group('modelo de cliente', () {
    test('nuevos nacen en usePreferredPrice false con nivel 1', () {
      final created = CreateClient(name: 'Nuevo');
      expect(created.usePreferredPrice, isFalse);
      expect(created.defaultPriceLevel, 1);

      final parsed = CreateClient.fromJson({'name': 'Nuevo'});
      expect(parsed.usePreferredPrice, isFalse);
      expect(parsed.defaultPriceLevel, 1);
    });

    test('legacy sin flag se lee como usePreferredPrice true con nivel 1', () {
      final client = ClientInDb.fromJson({
        'id': 'legacy',
        'name': 'Cliente legacy',
        'createdAt': 0,
      });
      expect(client.usePreferredPrice, isTrue);
      expect(client.defaultPriceLevel, 1);

      final base = BaseClient.fromJson({'name': 'Legacy'});
      expect(base.usePreferredPrice, isTrue);
      expect(base.defaultPriceLevel, 1);
    });

    test('UpdateClient conserva usePreferredPrice false y el nivel', () {
      final json = UpdateClient(
        usePreferredPrice: false,
        defaultPriceLevel: 1,
      ).toJson();

      expect(json['usePreferredPrice'], isFalse);
      expect(json['defaultPriceLevel'], 1);
    });
  });
}
