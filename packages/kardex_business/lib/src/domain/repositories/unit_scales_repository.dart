import 'package:kardex_business/src/data/data.dart';
import 'package:kardex_business/src/domain/models/unit_scale/unit_scale_model.dart';
import 'package:kardex_business/src/domain/responses/list_responses.dart';

class UnitScalesRepository {
  final UnitScalesDataSource unitScalesDataSource;

  UnitScalesRepository(this.unitScalesDataSource);

  List<UnitScaleInDb> _unitScales = [];

  List<UnitScaleInDb> get unitScales => _unitScales;

  Future<UnitScaleInDb> createUnitScale(CreateUnitScale createUnitScale) async {
    final result = await unitScalesDataSource.createUnitScale(createUnitScale.toJson());
    final newScale = UnitScaleInDb.fromJson(result);
    _unitScales = [newScale, ..._unitScales];
    return newScale;
  }

  Future<List<UnitScaleInDb>> getAllUnitScales() async {
    final results = await unitScalesDataSource.getAllUnitScales();
    final response = ListResponse<UnitScaleInDb>.fromJson(
      results,
      UnitScaleInDb.fromJson,
    );

    _unitScales = response.data;
    _unitScales.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return _unitScales;
  }

  Future<UnitScaleInDb?> getUnitScaleById(String unitScaleId) async {
    final result = await unitScalesDataSource.getUnitScaleById(unitScaleId);
    if (result == null) return null;
    return UnitScaleInDb.fromJson(result);
  }

  Future<List<UnitScaleInDb>> searchUnitScaleByKeywordLocal(String keyword) async {
    if (keyword.isEmpty) return _unitScales;
    return _unitScales
        .where(
          (s) =>
              s.name.toLowerCase().contains(keyword.toLowerCase()) ||
              s.baseUnit.toLowerCase().contains(keyword.toLowerCase()),
        )
        .toList();
  }

  Future<UnitScaleInDb?> updateUnitScaleById(
    String unitScaleId,
    UpdateUnitScale unitScale,
  ) async {
    final result = await unitScalesDataSource.updateUnitScaleById(
      unitScaleId,
      unitScale.toJson(),
    );
    if (result == null) return null;

    final updated = UnitScaleInDb.fromJson(result);
    final index = _unitScales.indexWhere((s) => s.id == unitScaleId);
    if (index != -1) {
      _unitScales[index] = updated;
    }
    return updated;
  }

  Future<UnitScaleInDb?> deleteUnitScaleById(String unitScaleId) async {
    final result = await unitScalesDataSource.deleteUnitScaleById(unitScaleId);
    if (result == null) return null;

    final deleted = UnitScaleInDb.fromJson(result);
    _unitScales.removeWhere((s) => s.id == unitScaleId);
    return deleted;
  }
}
