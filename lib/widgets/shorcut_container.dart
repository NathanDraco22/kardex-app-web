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
  final keyMapper = <String, (LogicalKeyboardKey, bool)>{
    "A": (LogicalKeyboardKey.keyA, true),
    "G": (LogicalKeyboardKey.keyG, true),
    "1": (LogicalKeyboardKey.digit1, true),
    "2": (LogicalKeyboardKey.digit2, true),
    "3": (LogicalKeyboardKey.digit3, true),
    "4": (LogicalKeyboardKey.digit4, true),
    "5": (LogicalKeyboardKey.digit5, true),
    "6": (LogicalKeyboardKey.digit6, true),
    "7": (LogicalKeyboardKey.digit7, true),
    "8": (LogicalKeyboardKey.digit8, true),
    "9": (LogicalKeyboardKey.digit9, true),
    "ESC": (LogicalKeyboardKey.escape, false),
    "ESCAPE": (LogicalKeyboardKey.escape, false),
  };

  final activatorMapper = <SingleActivator, VoidCallback>{};
  final callBackMapper = <String, void Function()?>{};

  @override
  void initState() {
    for (var entry in keyMapper.entries) {
      final (logicalKey, isCtrl) = entry.value;
      activatorMapper.putIfAbsent(SingleActivator(logicalKey, control: isCtrl), () {
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
