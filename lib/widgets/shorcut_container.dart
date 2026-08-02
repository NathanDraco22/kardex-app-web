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
  final keyMapper = <String, (List<LogicalKeyboardKey>, bool)>{
    "A": ([LogicalKeyboardKey.keyA], true),
    "G": ([LogicalKeyboardKey.keyG], true),
    "0": ([LogicalKeyboardKey.digit0, LogicalKeyboardKey.numpad0], true),
    "1": ([LogicalKeyboardKey.digit1, LogicalKeyboardKey.numpad1], true),
    "2": ([LogicalKeyboardKey.digit2, LogicalKeyboardKey.numpad2], true),
    "3": ([LogicalKeyboardKey.digit3, LogicalKeyboardKey.numpad3], true),
    "4": ([LogicalKeyboardKey.digit4, LogicalKeyboardKey.numpad4], true),
    "5": ([LogicalKeyboardKey.digit5, LogicalKeyboardKey.numpad5], true),
    "6": ([LogicalKeyboardKey.digit6, LogicalKeyboardKey.numpad6], true),
    "7": ([LogicalKeyboardKey.digit7, LogicalKeyboardKey.numpad7], true),
    "8": ([LogicalKeyboardKey.digit8, LogicalKeyboardKey.numpad8], true),
    "9": ([LogicalKeyboardKey.digit9, LogicalKeyboardKey.numpad9], true),
  };

  final activatorMapper = <SingleActivator, VoidCallback>{};
  final callBackMapper = <String, void Function()?>{};

  @override
  void initState() {
    for (var entry in keyMapper.entries) {
      final (logicalKeys, isCtrl) = entry.value;
      for (final logicalKey in logicalKeys) {
        activatorMapper.putIfAbsent(
          SingleActivator(logicalKey, control: isCtrl),
          () => () => callBackMapper[entry.key]?.call(),
        );
      }
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
