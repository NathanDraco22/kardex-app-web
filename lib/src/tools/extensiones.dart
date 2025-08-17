import 'package:flutter/material.dart';
import 'tools.dart';

extension BuildContextExtension on BuildContext {
  bool isMobile() => MediaQuery.sizeOf(this).width < maxPhoneScreenWidth;
}
