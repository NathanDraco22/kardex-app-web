import 'package:flutter/material.dart';

class TitleTextField extends StatelessWidget {
  const TitleTextField({
    super.key,
    required this.title,
    this.titleTextAlign,
    this.validator,
    this.initialValue,
  });

  final String? initialValue;
  final String title;
  final TextAlign? titleTextAlign;

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
          initialValue: initialValue,
          validator: validator,
        ),
      ],
    );
  }
}
