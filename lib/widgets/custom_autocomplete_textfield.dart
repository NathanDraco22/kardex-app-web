import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';

import 'search_debounce.dart';

class CustomAutocompleteTextfield<T> extends StatefulWidget {
  const CustomAutocompleteTextfield({
    super.key,
    this.initValue,
    required this.onSearch,
    required this.suggestionBuilder,
    required this.titleBuilder,
    this.hintText,
    this.validator,
    this.readOnly = false,
    this.onFieldSubmitted,
    this.onClose,
  });

  final T? initValue;

  final String Function(T value) titleBuilder;

  final String? hintText;

  final Future<List<T>> Function(String value) onSearch;

  final Widget Function(List<T> value, void Function(T value) close) suggestionBuilder;
  final void Function(T value)? onClose;

  final String? Function(String?)? validator;

  final bool readOnly;

  final void Function(String)? onFieldSubmitted;

  @override
  State<CustomAutocompleteTextfield<T>> createState() => _CustomAutocompleteTextfieldState<T>();
}

class _CustomAutocompleteTextfieldState<T> extends State<CustomAutocompleteTextfield<T>> {
  final TextEditingController controller = TextEditingController();

  T? currentValue;

  final textFieldKey = GlobalKey();
  Size textFieldSize = Size.zero;
  late Offset globalPosOffset;

  FocusNode alterTextFieldFocus = FocusNode();
  FocusNode mainTextFieldFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    Future(() {
      getTextFieldSize();
      final initValue = widget.initValue;
      if (initValue != null) {
        controller.text = widget.titleBuilder(initValue);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: mainTextFieldFocus,
      controller: controller,
      validator: widget.validator,
      style: const TextStyle(fontWeight: FontWeight.w500),
      key: textFieldKey,
      readOnly: widget.readOnly,
      onFieldSubmitted: widget.onFieldSubmitted,
      decoration: InputDecoration(hintText: widget.hintText),
      onChanged: (value) async {
        await displaySuggestions(context);
        mainTextFieldFocus.requestFocus();
      },
      onTap: () async {
        await displaySuggestions(context);
        mainTextFieldFocus.requestFocus();
      },
    );
  }

  Future<void> displaySuggestions(BuildContext context) async {
    getTextFieldSize();
    final res = await showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            TweenAnimationBuilder(
              duration: const Duration(milliseconds: 250),
              curve: Curves.decelerate,
              tween: SizeTween(begin: textFieldSize, end: textFieldSize * 6),
              builder: (context, value, child) {
                return Positioned(
                  top: globalPosOffset.dy,
                  left: globalPosOffset.dx,
                  width: textFieldSize.width,
                  height: value?.height ?? 0,
                  child: _InnerSearchTextField<T>(
                    widget.onSearch,
                    widget.suggestionBuilder,
                    controller,
                  ),
                );
              },
            ),
          ],
        );
      },
    );

    if (res == null) {
      controller.text = "";
      if (currentValue != null) {
        controller.text = widget.titleBuilder(currentValue as T);
      }
      return;
    }
    currentValue = res;
    controller.text = widget.titleBuilder(res);
    widget.onClose?.call(res);
  }

  void getTextFieldSize() {
    final renderBox = textFieldKey.currentContext!.findRenderObject() as RenderBox;
    globalPosOffset = renderBox.localToGlobal(Offset.zero);

    if (context.isMobile()) {
      globalPosOffset = Offset(globalPosOffset.dx, globalPosOffset.dy - kToolbarHeight);
    }

    setState(() {
      textFieldSize = renderBox.size;
    });
  }
}

class _InnerSearchTextField<T> extends StatefulWidget {
  const _InnerSearchTextField(this.onSearch, this.suggestionBuilder, this.controller);

  final Future<List<T>> Function(String value) onSearch;
  final TextEditingController controller;
  final Widget Function(List<T> value, void Function(T value) close) suggestionBuilder;

  @override
  State<_InnerSearchTextField<T>> createState() => _InnerSearchTextFieldState<T>();
}

class _InnerSearchTextFieldState<T> extends State<_InnerSearchTextField<T>> {
  List<T> suggestions = [];
  bool isSearching = false;
  void close(dynamic value) => Navigator.pop(context, value);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          SearchFieldDebounced(
            duration: const Duration(milliseconds: 300),
            hasPrefixIcon: false,
            controller: widget.controller,
            autoFocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (value) {
              if (suggestions.isNotEmpty) {
                close(suggestions.first);
              }
            },
            onSearch: (value) async {
              if (value.isEmpty) return;
              isSearching = true;
              setState(() {});
              final res = await widget.onSearch(value.trim());
              isSearching = false;
              suggestions = res;
              setState(() {});
            },
          ),
          Builder(
            builder: (context) {
              if (isSearching) return const LinearProgressIndicator();
              return Expanded(child: widget.suggestionBuilder(suggestions, close));
            },
          ),
        ],
      ),
    );
  }
}
