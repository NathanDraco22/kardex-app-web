import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

class IconWidgets {
  static Icon get entryInventoryIcon => const Icon(
    FluentIcons.arrow_down_left_12_filled,
    color: Colors.blue,
  );
  static Icon get exitInventoryIcon => const Icon(
    FluentIcons.arrow_up_right_12_filled,
    color: Colors.red,
  );

  Icon getSupplierIcon({Color? color}) => Icon(
    FluentIcons.building_multiple_20_filled,
    color: color,
  );
}
