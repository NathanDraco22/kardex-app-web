import 'dart:async';

import 'package:flutter/material.dart';

class SearchFieldDebounced extends StatefulWidget {
  const SearchFieldDebounced({
    super.key,
    this.onSearch,
  });

  final void Function(String)? onSearch;

  @override
  State<SearchFieldDebounced> createState() => _SearchFieldDebouncedState();
}

class _SearchFieldDebouncedState extends State<SearchFieldDebounced> {
  Timer? _debounceTime;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) {
        _debounceTime?.cancel();
        _debounceTime = Timer(const Duration(milliseconds: 500), () {
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
