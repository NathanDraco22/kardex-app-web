import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/client/client_model.dart';
import 'package:kardex_app_front/src/domain/repositories/client_repository.dart';
import 'package:kardex_app_front/widgets/super_widgets/search_debounce.dart';

Future<ClientInDb?> showClientWithBalanceSearch(BuildContext context) async {
  return showDialog<ClientInDb>(
    context: context,
    builder: (context) => const _ClientWithBalanceSearchDialog(),
  );
}

class _ClientWithBalanceSearchDialog extends StatefulWidget {
  const _ClientWithBalanceSearchDialog();

  @override
  State<_ClientWithBalanceSearchDialog> createState() => _ClientWithBalanceSearchDialogState();
}

class _ClientWithBalanceSearchDialogState extends State<_ClientWithBalanceSearchDialog> {
  List<ClientInDb> _clients = [];
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _search(String keyword) async {
    if (keyword.isEmpty) {
      setState(() {
        _clients = [];
        _errorMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repository = context.read<ClientsRepository>();
      final results = await repository.searchClientWithBalance(keyword);
      if (mounted) {
        setState(() {
          _clients = results;
          _isLoading = false;
        });
      }
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
      title: const Text("Buscar Cliente con Saldo"),
      content: SizedBox(
        width: 500,
        height: 600,
        child: Column(
          children: [
            SearchFieldDebounced(
              autoFocus: true,
              onSearch: _search,
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage != null)
              Expanded(child: Center(child: Text("Error: $_errorMessage")))
            else if (_clients.isEmpty)
              const Expanded(child: Center(child: Text("Ingrese un nombre para buscar clientes")))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _clients.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final client = _clients[index];
                    return ListTile(
                      title: Text(client.name),
                      subtitle: Text("Saldo: ${(client.balance / 100).toStringAsFixed(2)}"),
                      onTap: () {
                        Navigator.pop(context, client);
                      },
                    );
                  },
                ),
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
}
