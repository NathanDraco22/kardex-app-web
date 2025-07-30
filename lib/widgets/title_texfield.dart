import 'package:flutter/material.dart';

class TitleTextField extends StatelessWidget {
  const TitleTextField({
    super.key,
    required this.title,
    this.titleTextAlign,
    this.validator,
    this.initialValue,
    this.focusNode,
    this.autofocus = false,
    this.onEditingComplete,
  });

  final FocusNode? focusNode;
  final bool autofocus;
  final String? initialValue;
  final String title;
  final TextAlign? titleTextAlign;
  final void Function()? onEditingComplete;

  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: titleTextAlign,
        ),
        TextFormField(
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
