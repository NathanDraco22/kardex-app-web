import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:kardex_app_front/src/tools/printers/print_manager.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('print_manager_auto_print_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  BranchInDb buildBranch() {
    return BranchInDb(
      id: 'branch-1',
      name: 'Sucursal Test',
      idCard: 'J0310000000001',
      address: 'Calle 1',
      email: 'test@example.com',
      phone: '8888-8888',
      createdAt: DateTime(2026, 1, 1),
    );
  }

  test('getAutoPrintOnBillingEnabled retorna false por defecto', () async {
    expect(await PrintManager.getAutoPrintOnBillingEnabled(), isFalse);
  });

  test('saveAutoPrintOnBillingEnabled persiste true y false', () async {
    await PrintManager.saveAutoPrintOnBillingEnabled(true);
    expect(await PrintManager.getAutoPrintOnBillingEnabled(), isTrue);

    await PrintManager.saveAutoPrintOnBillingEnabled(false);
    expect(await PrintManager.getAutoPrintOnBillingEnabled(), isFalse);
  });

  test('autoPrintIfEnabled retorna false sin errores cuando está desactivado', () async {
    final result = await PrintManager.autoPrintIfEnabled(Object(), buildBranch());
    expect(result, isFalse);
  });
}
