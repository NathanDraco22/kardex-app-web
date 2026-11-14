import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/tools/bank_breakdown_helper.dart';
import 'package:kardex_business/kardex_business.dart';

void main() {
  group('BankBreakdownHelper', () {
    test('extractBankFromReference extrae banco y es retrocompatible', () {
      expect(extractBankFromReference('BAC - 123456'), 'BAC');
      expect(extractBankFromReference('lafise - 998877'), 'LAFISE');
      expect(extractBankFromReference('BANPRO'), 'BANPRO');
      expect(extractBankFromReference('123456'), kUnspecifiedBankLabel);
      expect(extractBankFromReference(''), kUnspecifiedBankLabel);
      expect(extractBankFromReference(null), kUnspecifiedBankLabel);
    });

    test('groupReferencesByBank agrupa por monto desc y deja Sin especificar al final', () {
      final result = groupReferencesByBank([
        (bankReference: '123456', amount: 50000),
        (bankReference: 'BAC - 111', amount: 20000),
        (bankReference: 'LAFISE - 222', amount: 35000),
        (bankReference: 'BAC - 333', amount: 25000),
        (bankReference: '', amount: 10000),
      ]);

      expect(result.length, 3);
      expect(result[0].bankName, 'BAC');
      expect(result[0].count, 2);
      expect(result[0].totalCents, 45000);

      expect(result[1].bankName, 'LAFISE');
      expect(result[1].count, 1);
      expect(result[1].totalCents, 35000);

      expect(result[2].bankName, kUnspecifiedBankLabel);
      expect(result[2].count, 2);
      expect(result[2].totalCents, 60000);
    });
  });

  group('ShiftArqueoDocument retrocompatibilidad bankReference', () {
    test('parsea bankReference cuando viene y null cuando se omite', () {
      final withRef = ShiftArqueoDocument.fromJson({
        'id': 'doc-1',
        'docNumber': 'F-001',
        'amount': 15000,
        'paymentMethod': 'transfer',
        'bankReference': 'BAC - 554433',
        'createdAt': 1700000000000,
        'counted': true,
      });
      expect(withRef.bankReference, 'BAC - 554433');

      final withoutRef = ShiftArqueoDocument.fromJson({
        'id': 'doc-2',
        'docNumber': 'F-002',
        'amount': 10000,
        'paymentMethod': 'transfer',
        'createdAt': 1700000000000,
        'counted': true,
      });
      expect(withoutRef.bankReference, isNull);
    });
  });
}
