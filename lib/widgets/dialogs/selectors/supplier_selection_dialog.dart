import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/supplier/supplier_model.dart';
import 'package:kardex_app_front/src/domain/repositories/supplier_repository.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

Future<SupplierInDb?> showSupplierSelectionDialog(BuildContext context) async {
  return await showDialog<SupplierInDb?>(
    context: context,
    builder: (context) => const SupplierSelectionDialog(),
  );
}

class SupplierSelectionDialog extends StatefulWidget {
  const SupplierSelectionDialog({super.key});

  @override
  State<SupplierSelectionDialog> createState() => _SupplierSelectionDialogState();
}

class _SupplierSelectionDialogState extends State<SupplierSelectionDialog> {
  List<SupplierInDb> _suppliers = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _searchSuppliers(String keyword) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (keyword.isEmpty) {
      setState(() {
        _suppliers = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final suppliersRepo = context.read<SuppliersRepository>();
      final suppliers = await suppliersRepo.searchSupplierByKeyword(keyword);
      setState(() {
        _suppliers = suppliers;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Seleccionar Proveedor"),
      content: SizedBox(
        width: 500,
        height: 600,
        child: Column(
          children: [
            SearchFieldDebounced(
              autoFocus: true,
              onSearch: _searchSuppliers,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text("Error: $_errorMessage"));
    }

    if (_suppliers.isEmpty) {
      return const Center(child: Text("No se encontraron proveedores"));
    }

    return ListView.separated(
      itemCount: _suppliers.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final supplier = _suppliers[index];
        
        final subtitleParts = <String>[];
        if (supplier.cardId != null && supplier.cardId!.isNotEmpty) {
          subtitleParts.add("Cédula/RUC: ${supplier.cardId}");
        }
        if (supplier.phone != null && supplier.phone!.isNotEmpty) {
          subtitleParts.add("Tel: ${supplier.phone}");
        }
        subtitleParts.add("${supplier.creditDays} días de crédito");

        return ListTile(
          leading: CircleAvatar(
            child: Text(supplier.name.isNotEmpty ? supplier.name.substring(0, 1).toUpperCase() : "?"),
          ),
          title: Text(supplier.name),
          subtitle: Text(subtitleParts.join(" | ")),
          onTap: () {
            Navigator.pop(context, supplier);
          },
        );
      },
    );
  }
}
