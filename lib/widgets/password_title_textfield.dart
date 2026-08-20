import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    required this.title,
    this.icon,
    this.controller,
    this.validator,
    this.onChanged,
    this.onEditingComplete,
  });

  final String title;
  final IconData? icon;
  final TextEditingController? controller;
  final String? Function(String? value)? validator;
  final void Function(String value)? onChanged;
  final void Function()? onEditingComplete;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.title),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          obscureText: _isObscured,
          autocorrect: false,
          enableSuggestions: false,

          decoration: InputDecoration(
            icon: widget.icon != null ? Icon(widget.icon) : null,
            suffixIcon: IconButton(
              icon: Icon(
                _isObscured ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                _isObscured = !_isObscured;
                setState(() {});
              },
            ),
          ),
        ),
      ],
    );
  }
}
