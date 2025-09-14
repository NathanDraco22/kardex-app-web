import 'package:kardex_app_front/src/data/data.dart';
import 'package:kardex_app_front/src/domain/models/unit/unit_model.dart';
import 'package:kardex_app_front/src/domain/responses/list_responses.dart';

class UnitsRepository {
  final UnitsDataSource unitsDataSource;

  UnitsRepository(this.unitsDataSource);

  List<UnitInDb> _units = [];

  List<UnitInDb> get units => _units;

  Future<UnitInDb> createUnit(CreateUnit createUnit) async {
    final result = await unitsDataSource.createUnit(createUnit.toJson());
    final newUnit = UnitInDb.fromJson(result);
    _units = [newUnit, ..._units];
    return newUnit;
  }

  Future<List<UnitInDb>> getAllUnits() async {
    final results = await unitsDataSource.getAllUnits();
    final response = ListResponse<UnitInDb>.fromJson(
      results,
      UnitInDb.fromJson,
    );

    _units = response.data;
    _units.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return _units;
  }

  Future<UnitInDb?> getUnitById(String unitId) async {
    final result = await unitsDataSource.getUnitById(unitId);
    if (result == null) return null;
    return UnitInDb.fromJson(result);
  }

  Future<List<UnitInDb>> searchUnitByKeyword(String keyword) async {
    final result = await unitsDataSource.searchUnitByKeyword(keyword);
    final response = ListResponse<UnitInDb>.fromJson(
      result,
      UnitInDb.fromJson,
    );
    return response.data;
  }

  Future<List<UnitInDb>> searchUnitByKeywordLocal(String keyword) async {
    final result = units
        .where(
          (u) => u.name.toLowerCase().contains(
            keyword.toLowerCase(),
          ),
        )
        .toList();
    return result;
  }

  Future<UnitInDb?> updateUnitById(
    String unitId,
    UpdateUnit unit,
  ) async {
    final result = await unitsDataSource.updateUnitById(
      unitId,
      unit.toJson(),
    );
    if (result == null) return null;

    final updatedUnit = UnitInDb.fromJson(result);
    final index = _units.indexWhere((u) => u.id == unitId);
    if (index != -1) {
      _units[index] = updatedUnit;
    }
    return updatedUnit;
  }

  Future<UnitInDb?> deleteUnitById(String unitId) async {
    final result = await unitsDataSource.deleteUnitById(unitId);
    if (result == null) return null;

    final deletedUnit = UnitInDb.fromJson(result);
    _units.removeWhere((u) => u.id == unitId);
    return deletedUnit;
  }
}
