import 'dart:async';

import 'package:flutter/material.dart';

class SearchFieldDebounced extends StatefulWidget {
  const SearchFieldDebounced({
    super.key,
    this.controller,
    this.onSearch,
    this.autoFocus = false,
    this.duration = const Duration(milliseconds: 500),
    this.hasPrefixIcon = true,
    this.textInputAction,
    this.onEditingComplete,
    this.onSubmitted,
    this.hintText,
    this.focusNode,
  });

  final Duration duration;
  final TextEditingController? controller;
  final void Function(String)? onSearch;
  final bool autoFocus;
  final bool hasPrefixIcon;
  final TextInputAction? textInputAction;
  final void Function()? onEditingComplete;
  final void Function(String)? onSubmitted;
  final String? hintText;
  final FocusNode? focusNode;

  @override
  State<SearchFieldDebounced> createState() => _SearchFieldDebouncedState();
}

class _SearchFieldDebouncedState extends State<SearchFieldDebounced> {
  Timer? _debounceTime;

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: widget.focusNode,
      controller: widget.controller,
      autofocus: widget.autoFocus,
      style: const TextStyle(fontWeight: FontWeight.w500),
      textInputAction: widget.textInputAction,
      onEditingComplete: widget.onEditingComplete ?? () {},
      onSubmitted: widget.onSubmitted,
      onChanged: (value) {
        _debounceTime?.cancel();
        _debounceTime = Timer(widget.duration, () {
          widget.onSearch?.call(value);
        });
      },
      decoration: InputDecoration(
        isCollapsed: false,
        border: const OutlineInputBorder(),
        prefixIcon: widget.hasPrefixIcon ? const Icon(Icons.search, size: 16) : null,
        label: const Text("Buscar..."),
        hintText: widget.hintText,
      ),
    );
  }
}
