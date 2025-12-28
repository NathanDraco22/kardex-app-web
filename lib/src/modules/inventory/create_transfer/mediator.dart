import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/branch/branch.dart';
import 'package:kardex_app_front/widgets/tables/transfer_product_table.dart';

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
  final TransferProductTableController controller = TransferProductTableController();
  final TransferHeaderData headerData = TransferHeaderData();

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
