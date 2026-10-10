import 'dart:convert';
import 'package:kardex_business/kardex_business.dart';
import 'cash_counter_models.dart';

class CashCounterStorage with HiveService {
  static const String _boxName = 'cash_counter_box';
  static const String _keyCurrentCount = 'current_cash_count';
  static const String _keyExchangeRate = 'last_exchange_rate';

  static final CashCounterStorage _instance = CashCounterStorage._internal();
  factory CashCounterStorage() => _instance;
  CashCounterStorage._internal();

  /// Guarda el conteo único sobreescribiendo el anterior
  Future<void> saveCount(CashCountRecord record) async {
    final box = await getBox(_boxName);
    final jsonString = json.encode(record.toJson());
    await box.put(_keyCurrentCount, jsonString);
    await box.put(_keyExchangeRate, record.exchangeRate);
  }

  /// Recupera el último conteo guardado
  Future<CashCountRecord?> getCount() async {
    final box = await getBox(_boxName);
    final jsonString = box.get(_keyCurrentCount);
    if (jsonString == null) return null;

    try {
      final Map<String, dynamic> data = json.decode(jsonString);
      return CashCountRecord.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  /// Limpia el conteo actual
  Future<void> clearCount() async {
    final box = await getBox(_boxName);
    await box.delete(_keyCurrentCount);
  }

  Future<double> getLastExchangeRate() async {
    final box = await getBox(_boxName);
    final val = box.get(_keyExchangeRate);
    if (val is num) {
      return val.toDouble();
    }
    return 36.62;
  }

  Future<void> saveLastExchangeRate(double rate) async {
    final box = await getBox(_boxName);
    await box.put(_keyExchangeRate, rate);
  }
}
