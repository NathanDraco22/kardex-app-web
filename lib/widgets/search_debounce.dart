import 'dart:async';

import 'package:flutter/material.dart';

class SearchFieldDebounced extends StatefulWidget {
  const SearchFieldDebounced({
    super.key,
    this.controller,
    this.onSearch,
    this.autoFocus = false,
    this.duration = const Duration(milliseconds: 500),
  });

  final Duration duration;
  final TextEditingController? controller;
  final void Function(String)? onSearch;
  final bool autoFocus;

  @override
  State<SearchFieldDebounced> createState() => _SearchFieldDebouncedState();
}

class _SearchFieldDebouncedState extends State<SearchFieldDebounced> {
  Timer? _debounceTime;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      autofocus: widget.autoFocus,
      style: const TextStyle(fontWeight: FontWeight.w500),
      onEditingComplete: () {},
      onChanged: (value) {
        _debounceTime?.cancel();
        _debounceTime = Timer(widget.duration, () {
          widget.onSearch?.call(value);
        });
      },
      decoration: const InputDecoration(
        isCollapsed: false,
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.search, size: 16),
        label: Text("Buscar..."),
      ),
    );
  }
}
