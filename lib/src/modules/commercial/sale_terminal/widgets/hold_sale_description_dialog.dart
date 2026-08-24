import 'package:flutter/material.dart';

/// Muestra un diálogo emergente ágil para ingresar o modificar el título / referencia
/// de una venta en espera antes de guardarla localmente.
Future<String?> showHoldSaleDescriptionDialog(
  BuildContext context, {
  String initialValue = '',
  String? clientName,
  bool isEditing = false,
}) async {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return _HoldSaleDescriptionDialogContent(
        initialValue: initialValue,
        clientName: clientName,
        isEditing: isEditing,
      );
    },
  );
}

class _HoldSaleDescriptionDialogContent extends StatefulWidget {
  const _HoldSaleDescriptionDialogContent({
    required this.initialValue,
    this.clientName,
    required this.isEditing,
  });

  final String initialValue;
  final String? clientName;
  final bool isEditing;

  @override
  State<_HoldSaleDescriptionDialogContent> createState() => _HoldSaleDescriptionDialogContentState();
}

class _HoldSaleDescriptionDialogContentState extends State<_HoldSaleDescriptionDialogContent> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleText = widget.isEditing ? "Editar Referencia de Venta" : "Guardar Venta en Espera";

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.bookmark_outline_rounded,
              color: Colors.amber.shade900,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              titleText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.clientName != null && widget.clientName!.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Colors.grey.shade700),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        "Cliente: ${widget.clientName}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Text(
              "Ingresa un título, nota o referencia para identificar y retomar esta venta fácilmente:",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: "Título o Referencia",
                hintText: "Ej: En Espera, Venta pendiente, ...",
                prefixIcon: const Icon(Icons.edit_note),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancelar"),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onPressed: _submit,
          icon: Icon(widget.isEditing ? Icons.check : Icons.pause_rounded, size: 18),
          label: Text(
            widget.isEditing ? "Guardar Cambios" : "Poner en Espera",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
