import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  group('UserRoleInDb & ModulesCatalog', () {
    test('UserRoleInDb.fromJson parses updatedAt and isDefault correctly', () {
      final json = {
        'id': 'Admin',
        'name': 'Admin',
        'access': ['all'],
        'createdAt': 1700000000000,
        'updatedAt': 1700000500000,
        'isDefault': true,
      };

      final role = UserRoleInDb.fromJson(json);

      expect(role.id, 'Admin');
      expect(role.name, 'Admin');
      expect(role.access, ['all']);
      expect(role.createdAt, DateTime.fromMillisecondsSinceEpoch(1700000000000));
      expect(role.updatedAt, DateTime.fromMillisecondsSinceEpoch(1700000500000));
      expect(role.isDefault, isTrue);
    });

    test('ModulesCatalog.fromJson parses modules and submodules', () {
      final json = {
        'allAccessKey': 'all',
        'modules': [
          {
            'key': 'clients',
            'name': 'Clientes',
            'description': 'Gestión de clientes',
            'submodules': [],
          },
          {
            'key': 'commercial',
            'name': 'Comercial',
            'description': 'Ventas y facturación',
            'submodules': [
              {
                'key': 'createInvoice',
                'name': 'Facturación y Caja',
                'description': 'Emitir facturas',
              },
            ],
          },
        ],
      };

      final catalog = ModulesCatalog.fromJson(json);

      expect(catalog.allAccessKey, 'all');
      expect(catalog.modules.length, 2);
      expect(catalog.modules[0].key, 'clients');
      expect(catalog.modules[0].submodules, isEmpty);
      expect(catalog.modules[1].key, 'commercial');
      expect(catalog.modules[1].submodules.length, 1);
      expect(catalog.modules[1].submodules.first.key, 'createInvoice');
    });
  });
}
