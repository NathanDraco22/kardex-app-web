import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/constants/shortcut_registry.dart';
import 'package:kardex_app_front/cubits/shortcuts/shortcuts_cubit.dart';
import 'package:kardex_business/kardex_business.dart';

class ShortcutsMenuScreen extends StatelessWidget {
  const ShortcutsMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accesos Directos"),
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShortcutsCubit, ShortcutsState>(
      buildWhen: (prev, curr) =>
          prev.isLoading != curr.isLoading ||
          !listEquals(prev.routes, curr.routes),
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.shortcuts.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FluentIcons.bookmark_multiple_24_filled,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  "Sin accesos directos",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Mantén presionado un submódulo para agregarlo aquí",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return Center(
          child: ReorderableListView(
            buildDefaultDragHandles: false,
            onReorderItem: (oldIndex, newIndex) {
              final list = [...state.shortcuts];
              final item = list.removeAt(oldIndex);
              list.insert(newIndex, item);
              context.read<ShortcutsCubit>().updateOrder(list);
            },
            children: [
              for (int i = 0; i < state.shortcuts.length; i++)
                _ShortcutTile(
                  key: ValueKey(state.shortcuts[i].routeName),
                  shortcut: state.shortcuts[i],
                  index: i,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ShortcutTile extends StatelessWidget {
  final Shortcut shortcut;
  final int index;

  const _ShortcutTile({
    super.key,
    required this.shortcut,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final info = ShortcutRouteRegistry.routes[shortcut.routeName];
    final title = info?.title ?? shortcut.routeName;
    final icon = info?.icon ?? Icons.link;
    final color = info?.color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onLongPress: () async {
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
                    items: const [
                      PopupMenuItem<String>(
                        value: 'remove',
                        child: Text('Remover de accesos directos'),
                      ),
                    ],
                  );

                  if (result == 'remove' && context.mounted) {
                    context.read<ShortcutsCubit>().removeShortcut(shortcut.routeName);
                  }
                },
                child: ListTile(
                  leading: Icon(
                    icon,
                    size: 32,
                    color: color ?? Colors.indigo.shade400,
                  ),
                  title: Text(title),
                  onTap: () => context.pushNamed(shortcut.routeName),
                ),
              ),
            ),
            ReorderableDragStartListener(
              index: index,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.drag_handle, size: 28, color: Colors.grey),
              ),
            ),
          ],
        ),
        const Divider(height: 0.0),
      ],
    );
  }
}
