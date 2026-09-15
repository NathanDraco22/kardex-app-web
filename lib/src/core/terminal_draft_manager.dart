import 'package:kardex_app_front/widgets/dialogs/models/commercial_product_result.dart';
import 'package:kardex_business/kardex_business.dart';

typedef SaleTerminalItemDraft = HoldSaleItem;
typedef SaleTerminalDraft = HoldSaleInDb;

extension HoldSaleItemToCommercial on HoldSaleItem {
  CommercialProductResult toCommercialProductResult() {
    final result = CommercialProductResult(
      product: product,
      defaultPriceLevel: selectedPriceLevel,
    );
    result.newPrice = newPrice;
    result.selectedPriceLevel = selectedPriceLevel;
    result.quantity = quantity;
    result.selectedUnitIndex = selectedUnitIndex;
    result.conversionFactor = conversionFactor;
    result.selectedUnitName = selectedUnitName;
    result.selectedDiscount = selectedDiscount;
    return result;
  }
}

extension CommercialProductResultToHoldSaleItem on CommercialProductResult {
  HoldSaleItem toHoldSaleItem() {
    return HoldSaleItem(
      product: product,
      newPrice: newPrice,
      selectedPriceLevel: selectedPriceLevel,
      quantity: quantity,
      selectedUnitIndex: selectedUnitIndex,
      conversionFactor: conversionFactor,
      selectedUnitName: selectedUnitName,
      selectedDiscount: selectedDiscount,
    );
  }
}

class SaleTerminalDraftManager {
  static final SaleTerminalDraftManager _instance = SaleTerminalDraftManager._internal();
  factory SaleTerminalDraftManager() => _instance;
  SaleTerminalDraftManager._internal();

  final _repo = HoldSalesRepository(HoldSalesDataSource.instance);

  /// Retorna todas las ventas en espera guardadas en el servidor para la sucursal,
  /// ordenadas de más reciente a más antigua.
  Future<List<HoldSaleInDb>> getDrafts(
    String branchId, {
    String? createdBy,
    String? search,
    int limit = 500,
  }) async {
    final params = HoldSaleFilterParams(
      branchId: branchId,
      createdBy: createdBy,
      search: search,
      limit: limit,
    );
    return await _repo.getAllHoldSales(params);
  }

  /// Guarda una nueva venta en espera o actualiza la existente si viene [existingId].
  Future<HoldSaleInDb> saveDraft(
    String branchId,
    CreateHoldSale draft, {
    String? existingId,
  }) async {
    if (existingId != null && existingId.trim().isNotEmpty) {
      final updated = await _repo.updateHoldSaleById(
        existingId,
        UpdateHoldSale(
          description: draft.description,
          client: draft.client,
          selectedPriceLevel: draft.selectedPriceLevel,
          isWholesale: draft.isWholesale,
          selectedPaymentType: draft.selectedPaymentType,
          items: draft.items,
          totalQuantity: draft.totalQuantity,
          totalAmount: draft.totalAmount,
        ),
      );
      if (updated != null) return updated;
    }

    return await _repo.createHoldSale(draft);
  }

  /// Actualiza la descripción o referencia de una venta en espera en el servidor.
  Future<HoldSaleInDb?> updateDescription(String draftId, String newDescription) async {
    return await _repo.updateHoldSaleById(
      draftId,
      UpdateHoldSale(description: newDescription),
    );
  }

  /// Elimina una venta en espera por su id en el servidor.
  Future<void> removeDraft(String branchId, String draftId) async {
    await _repo.deleteHoldSaleById(draftId);
  }

  /// Elimina todas las ventas en espera de la sucursal en el servidor.
  Future<void> clearAllDrafts(String branchId) async {
    await _repo.deleteAllHoldSalesByBranch(branchId);
  }

  /// Retorna la cantidad de ventas en espera de la sucursal en el servidor.
  Future<int> countDrafts(String branchId) async {
    final drafts = await getDrafts(branchId);
    return drafts.length;
  }
}
