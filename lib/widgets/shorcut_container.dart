import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisShortcutNotification extends Notification {
  const RegisShortcutNotification({
    this.onAdd,
    this.onSave,
  });

  final Function()? onAdd;
  final Function()? onSave;
}

class AddIntent extends Intent {
  const AddIntent();
}

class SaveIntent extends Intent {
  const SaveIntent();
}

class ShortcutContainer extends StatefulWidget {
  const ShortcutContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<ShortcutContainer> createState() => _ShortcutContainerState();
}

class _ShortcutContainerState extends State<ShortcutContainer> {
  Function()? _onAdd;
  Function()? _onSave;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<RegisShortcutNotification>(
      onNotification: (notification) {
        _onAdd = notification.onAdd ?? _onAdd;
        _onSave = notification.onSave ?? _onSave;

        return true;
      },
      child: CallbackShortcuts(
        bindings: <SingleActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.keyA, control: true): () => _onAdd?.call(),
          const SingleActivator(LogicalKeyboardKey.keyG, control: true): () => _onSave?.call(),
        },
        child: Focus(
          autofocus: true,
          child: widget.child,
        ),
      ),
    );
  }
}
