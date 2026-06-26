import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/widgets/tables/transfer_product_table.dart';

import 'mobile/widgets.dart';

class TransferHeaderData {
  BranchInDb? destinationBranch;
  String? observations;

  // Assuming origin is current branch, so we don't store it here explicitly or maybe we do.
  // For now, let's keep it simple.

  bool hasNullFields() {
    final fields = [destinationBranch];
    return fields.contains(null);
  }

  void clear() {
    destinationBranch = null;
    observations = null;
  }
}

class CreateTransferNotifier extends ChangeNotifier {
  final TransferProductTableController controller;
  final TransferHeaderData headerData;

  final Map<String, GlobalKey<MobileProductCardState>> cardKeys = {};
  final Map<String, FocusNode> quantityFocusNodes = {};

  CreateTransferNotifier({
    List<TransferProductRow>? initialRows,
    BranchInDb? destinationBranch,
    String? observations,
  }) : controller = TransferProductTableController()..rows = List.from(initialRows ?? []),
       headerData = TransferHeaderData()
         ..destinationBranch = destinationBranch
         ..observations = observations;

  GlobalKey<MobileProductCardState> getOrCreateCardKey(String productId) {
    return cardKeys.putIfAbsent(productId, () => GlobalKey<MobileProductCardState>());
  }

  void registerCardKey(String productId, GlobalKey<MobileProductCardState> key) {
    cardKeys[productId] = key;
  }

  void unregisterCardKey(String productId) {
    cardKeys.remove(productId);
  }

  void registerQuantityFocusNode(String productId, FocusNode node) {
    quantityFocusNodes[productId] = node;
  }

  void unregisterQuantityFocusNode(String productId) {
    quantityFocusNodes.remove(productId);
  }

  bool hasProductWithZeroValue() {
    final rows = controller.rows;
    for (var row in rows) {
      if (row.quantity == 0) return true;
    }
    return false;
  }

  void refresh() => notifyListeners();
}

class CreateTransferMediator extends InheritedNotifier<CreateTransferNotifier> {
  const CreateTransferMediator({super.key, required super.child, super.notifier});

  TransferHeaderData get headerData => notifier!.headerData;
  TransferProductTableController get productTableController => notifier!.controller;

  bool hasAllRequiredFields() => ![headerData.hasNullFields(), productTableController.rows.isEmpty].contains(true);

  bool hasProductWithZeroValue() => notifier!.hasProductWithZeroValue();

  void refresh() => notifier!.refresh();

  static CreateTransferMediator? read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<CreateTransferMediator>();
    return element?.widget as CreateTransferMediator?;
  }

  static CreateTransferMediator? watch(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CreateTransferMediator>()!;
}
