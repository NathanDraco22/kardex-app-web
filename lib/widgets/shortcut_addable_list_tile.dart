import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/cubits/shortcuts/shortcuts_cubit.dart';

class ShortcutAddableListTile extends StatelessWidget {
  final String routeName;
  final Widget child;

  const ShortcutAddableListTile({
    super.key,
    required this.routeName,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShortcutsCubit, ShortcutsState>(
      buildWhen: (prev, curr) => prev.routes.toSet() != curr.routes.toSet(),
      builder: (context, state) {
        final isAdded = state.routes.contains(routeName);

        return Stack(
          children: [
            GestureDetector(
              onLongPress: () async {
                final cubit = context.read<ShortcutsCubit>();

                final renderBox = context.findRenderObject() as RenderBox;
                final offset = renderBox.localToGlobal(Offset.zero);
                final size = renderBox.size;

                final result = await showMenu<String>(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    offset.dx,
                    offset.dy + size.height / 2,
                    offset.dx + size.width,
                    offset.dy + size.height / 2,
                  ),
                  items: [
                    PopupMenuItem<String>(
                      value: isAdded ? 'remove' : 'add',
                      child: Text(
                        isAdded
                            ? 'Remover de accesos directos'
                            : 'Agregar a accesos directos',
                      ),
                    ),
                  ],
                );

                if (result == 'add') {
                  cubit.addShortcut(routeName);
                } else if (result == 'remove') {
                  cubit.removeShortcut(routeName);
                }
              },
              child: child,
            ),
            if (isAdded)
              const Positioned(
                top: 12,
                right: 12,
                child: Icon(
                  FluentIcons.bookmark_16_filled,
                  size: 16,
                  color: Colors.indigo,
                ),
              ),
          ],
        );
      },
    );
  }
}
