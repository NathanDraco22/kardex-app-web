import 'package:kardex_app_front/src/tools/tools.dart';
import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';

import 'search_debounce.dart';

class CustomAutocompleteTextfield<T> extends StatefulWidget {
  const CustomAutocompleteTextfield({
    super.key,
    this.controller,
    this.initValue,
    required this.onSearch,
    required this.suggestionBuilder,
    required this.titleBuilder,
    this.hintText,
    this.validator,
    this.readOnly = false,
    this.allowFreeText = false,
    this.onFieldSubmitted,
    this.onClose,
    this.onChanged,
  });

  final TextEditingController? controller;
  final T? initValue;

  final String Function(T value) titleBuilder;

  final String? hintText;

  final Future<List<T>> Function(String value) onSearch;

  final Widget Function(List<T> value, void Function(T value) close) suggestionBuilder;
  final void Function(T value)? onClose;

  final String? Function(String?)? validator;

  final bool readOnly;

  /// Permite conservar el texto escrito cuando el usuario cierra la lista de
  /// sugerencias sin seleccionar una opción. Útil para unidades de medida
  /// libres que no están en el catálogo (ej. "Cuarto de Libra").
  final bool allowFreeText;

  final void Function(String)? onFieldSubmitted;
  final ValueChanged<String>? onChanged;

  @override
  State<CustomAutocompleteTextfield<T>> createState() => _CustomAutocompleteTextfieldState<T>();
}

class _CustomAutocompleteTextfieldState<T> extends State<CustomAutocompleteTextfield<T>> {
  late final TextEditingController controller;
  bool _ownsController = false;

  /// Evita que el `onChanged` del campo exterior procese el texto mientras el
  /// popup de sugerencias está abierto. El popup comparte el controlador, así
  /// que el texto final se propaga recién al cerrarlo.
  bool _dialogOpen = false;

  T? currentValue;

  final textFieldKey = GlobalKey();
  Size textFieldSize = Size.zero;
  late Offset globalPosOffset;

  FocusNode alterTextFieldFocus = FocusNode();
  FocusNode mainTextFieldFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      controller = widget.controller!;
    } else {
      _ownsController = true;
      controller = TextEditingController();
    }
    Future(() {
      getTextFieldSize();
      final initValue = widget.initValue;
      if (initValue != null && controller.text.isEmpty) {
        controller.text = widget.titleBuilder(initValue);
      }
    });
  }

  @override
  void dispose() {
    if (_ownsController) {
      controller.dispose();
    }
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
        // El popup comparte el controlador: no se notifica cada carácter aquí,
        // porque el texto completo se propaga al cerrar el popup.
        if (_dialogOpen) return;
        await displaySuggestions(context);
        if (!mounted) return;
        mainTextFieldFocus.requestFocus();
      },
      onTap: () async {
        await displaySuggestions(context);
        mainTextFieldFocus.requestFocus();
      },
    );
  }

  Future<void> displaySuggestions(BuildContext context) async {
    if (_dialogOpen) return;
    getTextFieldSize();
    _dialogOpen = true;

    T? res;
    try {
      res = await showDialog<T>(
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
    } finally {
      _dialogOpen = false;
    }

    if (!mounted) return;

    if (res == null) {
      if (widget.allowFreeText) {
        final text = controller.text.trim();
        if (currentValue != null && text != widget.titleBuilder(currentValue as T)) {
          currentValue = null;
        }
        widget.onChanged?.call(text);
        return;
      }
      if (currentValue != null) {
        controller.text = widget.titleBuilder(currentValue as T);
      } else {
        controller.text = "";
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
