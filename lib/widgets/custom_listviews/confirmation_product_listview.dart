import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/tools.dart';

class ConfirmationListItem {
  final String title;
  final int quantity;
  final int unitPrice;
  final int subtotal;

  ConfirmationListItem({
    required this.title,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });
}

class ConfirmationListData {
  final List<ConfirmationListItem> items;

  ConfirmationListData({required this.items});

  int get total {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }
}

class ConfirmationProductListView extends StatelessWidget {
  const ConfirmationProductListView({super.key, required this.data});

  final ConfirmationListData data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            separatorBuilder: (context, index) => const Divider(height: 0.0),
            itemCount: data.items.length,
            itemBuilder: (context, index) {
              final item = data.items[index];
              return ListTile(
                title: Text(item.title),
                subtitle: Row(
                  children: [
                    Expanded(child: Text(item.quantity.toString())),
                    Expanded(child: Text(NumberFormatter.convertToMoneyLike(item.unitPrice))),
                    Expanded(
                      child: Text(
                        NumberFormatter.convertToMoneyLike(item.subtotal),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(thickness: 2),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Total: ${NumberFormatter.convertToMoneyLike(data.total)}",
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
