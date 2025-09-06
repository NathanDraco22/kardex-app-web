import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/domain/models/product_sale_profile/product_sale_profile_model.dart';
import 'package:kardex_app_front/src/tools/input_formatters.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';

Future<Discount?> showDiscountDialog(BuildContext context, {Discount? discount}) async {
  return await showDialog<Discount?>(
    context: context,
    builder: (context) => DiscountDialog(
      discount: discount,
    ),
  );
}

class DiscountDialog extends StatefulWidget {
  const DiscountDialog({super.key, this.discount});

  final Discount? discount;

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  late Discount currentDiscount;

  @override
  void initState() {
    currentDiscount = widget.discount ?? Discount.defaultDiscount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Descuento"),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cerrar"),
        ),
        const SizedBox(width: 4),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, currentDiscount);
          },
          child: Builder(
            builder: (context) {
              String title = "Agregar";

              if (widget.discount != null) {
                title = "Actualizar";
              }

              return Text(title);
            },
          ),
        ),
      ],
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          TitleTextField(
            title: "Nombre",
            initialValue: currentDiscount.name,
            onChanged: (value) {
              currentDiscount.name = value;
            },
          ),
          TitleTextField(
            title: "Descuento en %",
            initialValue: currentDiscount.percentValue.toString(),
            keyboardType: TextInputType.number,
            inputFormatters: [IntegerTextInputFormatter()],
            onChanged: (value) {
              currentDiscount.percentValue = int.tryParse(value) ?? 0;
            },
          ),
          SwitchListTile(
            value: currentDiscount.isActive,
            title: const Text("Activo"),
            tileColor: Colors.grey.shade200,
            onChanged: (value) {
              setState(() {
                currentDiscount.isActive = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
