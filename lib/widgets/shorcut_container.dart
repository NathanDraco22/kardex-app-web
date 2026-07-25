import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisShortcutNotification extends Notification {
  const RegisShortcutNotification({
    required this.hotKey,
    required this.callback,
  });

  final String hotKey;
  final void Function() callback;
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
  final activatorMapper = <SingleActivator, VoidCallback>{};
  final keyMapper = {
    "A": LogicalKeyboardKey.keyA,
    "G": LogicalKeyboardKey.keyG,
    "1": LogicalKeyboardKey.digit1,
    "2": LogicalKeyboardKey.digit2,
    "3": LogicalKeyboardKey.digit3,
    "4": LogicalKeyboardKey.digit4,
    "5": LogicalKeyboardKey.digit5,
    "6": LogicalKeyboardKey.digit6,
    "7": LogicalKeyboardKey.digit7,
    "8": LogicalKeyboardKey.digit8,
    "9": LogicalKeyboardKey.digit9,
  };

  final callBackMapper = <String, void Function()?>{};

  @override
  void initState() {
    for (var entry in keyMapper.entries) {
      final logicalKey = keyMapper[entry.key];
      if (logicalKey == null) continue;
      activatorMapper.putIfAbsent(SingleActivator(logicalKey, control: true), () {
        return () => callBackMapper[entry.key]?.call();
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<RegisShortcutNotification>(
      onNotification: (notification) {
        callBackMapper[notification.hotKey.toUpperCase()] = notification.callback;
        return true;
      },
      child: CallbackShortcuts(
        bindings: activatorMapper,
        child: Focus(
          autofocus: true,
          child: widget.child,
        ),
      ),
    );
  }
}
