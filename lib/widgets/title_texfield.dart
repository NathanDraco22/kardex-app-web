import 'package:flutter/material.dart';

class TitleTextField extends StatelessWidget {
  const TitleTextField({
    super.key,
    required this.title,
    this.controller,
    this.titleTextAlign,
    this.validator,
    this.initialValue,
    this.focusNode,
    this.autofocus = false,
    this.maxLines = 1,
    this.onEditingComplete,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextCapitalization textCapitalization;
  final TextEditingController? controller;
  final int maxLines;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? initialValue;
  final String title;
  final TextAlign? titleTextAlign;
  final void Function()? onEditingComplete;

  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 6,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: titleTextAlign,
        ),
        TextFormField(
          maxLines: maxLines,
          onChanged: onChanged,
          textCapitalization: textCapitalization,
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          initialValue: initialValue,
          onEditingComplete: onEditingComplete,
          validator: validator,
        ),
      ],
    );
  }
}
