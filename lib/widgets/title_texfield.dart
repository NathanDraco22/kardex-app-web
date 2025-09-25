import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TitleTextField extends StatelessWidget {
  const TitleTextField({
    super.key,
    required this.title,
    this.keyboardType,
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
    this.inputFormatters,
    this.style,
    this.readOnly = false,
    this.onTap,
    this.textInputAction,
  });

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final TextEditingController? controller;
  final int maxLines;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? initialValue;
  final String title;
  final TextAlign? titleTextAlign;
  final TextStyle? style;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final void Function()? onTap;
  final void Function()? onEditingComplete;

  final String? Function(String? value)? validator;
  final void Function(String value)? onChanged;

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
          readOnly: readOnly,
          textInputAction: textInputAction,
          onTap: onTap,
          style: style ?? const TextStyle(fontWeight: FontWeight.w500),
          textAlign: titleTextAlign ?? TextAlign.start,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          onChanged: onChanged,
          keyboardType: keyboardType,
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
