import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Future<void> showSimpleSearchDialog<T>(
  BuildContext context, {
  required Future<T> Function(String value) searchFuture,
  required String title,
  required void Function(T value) onResult,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => SimpleSearchDialog<T>(
      title: title,
      searchFuture: searchFuture,
      onResult: onResult,
    ),
  );
}

class SimpleSearchDialog<T> extends StatefulWidget {
  const SimpleSearchDialog({super.key, required this.searchFuture, required this.onResult, required this.title});

  final Future<T> Function(String value) searchFuture;
  final String title;
  final void Function(T value) onResult;

  @override
  State<SimpleSearchDialog<T>> createState() => _SimpleSearchDialogState<T>();
}

class _SimpleSearchDialogState<T> extends State<SimpleSearchDialog<T>> {
  bool isLoading = false;
  bool error = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) async {
              final futureTask = widget.searchFuture(value);
              setState(() {
                isLoading = true;
                error = false;
              });
              try {
                final res = await futureTask;
                widget.onResult(res);
              } catch (e) {
                error = true;
              }

              setState(() {
                isLoading = false;
              });
            },
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Builder(
            builder: (context) {
              if (isLoading) return const LinearProgressIndicator();

              if (error) return const Text("No se encontro resultados");

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Cancelar"),
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
