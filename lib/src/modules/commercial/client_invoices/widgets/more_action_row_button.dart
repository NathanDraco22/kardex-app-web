import 'package:flutter/material.dart';

class MoreActionInvoiceRowButton extends StatelessWidget {
  const MoreActionInvoiceRowButton({
    super.key,
    required this.popUpItems,
  });

  final List<PopupMenuEntry<dynamic>> popUpItems;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return IconButton(
          focusNode: FocusNode(skipTraversal: true),
          onPressed: () {
            final renderBox = context.findRenderObject() as RenderBox;

            final globalPosOffset = renderBox.localToGlobal(Offset.zero);
            final size = renderBox.size;

            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                globalPosOffset.dx,
                globalPosOffset.dy + size.height,
                globalPosOffset.dx + size.width,
                globalPosOffset.dy + size.height,
              ),

              items: [
                ...popUpItems,
              ],
            );
          },
          icon: const Icon(Icons.more_vert),
          splashRadius: 16,
        );
      },
    );
  }
}
