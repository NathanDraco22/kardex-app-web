import 'package:flutter/material.dart';

class SearchProductDialogPanel extends StatelessWidget {
  const SearchProductDialogPanel({
    super.key,
    required this.child,
    this.showConstraints = true,
  });

  final Widget child;
  final bool showConstraints;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 700,
        child: Dialog(
          constraints: showConstraints ? const BoxConstraints(maxWidth: 700) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
