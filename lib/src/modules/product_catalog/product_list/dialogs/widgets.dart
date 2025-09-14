part of 'create_product_dialog.dart';

class _UnitFormField extends StatefulWidget {
  const _UnitFormField({
    required this.unitsMenuEntries,
    required this.creationMap,
    this.initialSelection,
  });

  final Iterable<DropdownMenuEntry<String>> unitsMenuEntries;
  final Map creationMap;
  final String? initialSelection;

  @override
  State<_UnitFormField> createState() => _UnitFormFieldState();
}

class _UnitFormFieldState extends State<_UnitFormField> {
  String? currentValue;

  late TextEditingController controller;

  @override
  void initState() {
    currentValue = widget.initialSelection;
    controller = TextEditingController(text: widget.initialSelection);
    controller.addListener(
      () {
        log(controller.text);
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      validator: (value) {
        if (currentValue == null || currentValue!.isEmpty) return "Campo requerido";
        return null;
      },
      builder: (field) {
        InputBorder? errorBorder;

        if (field.hasError) {
          errorBorder = const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2),
          );
        }

        return DropdownMenu(
          requestFocusOnTap: true,
          label: const Text("Unidad"),
          initialSelection: widget.initialSelection,
          controller: controller,
          inputDecorationTheme: InputDecorationTheme(
            enabledBorder: errorBorder,
          ),
          dropdownMenuEntries: widget.unitsMenuEntries.toList(),

          onSelected: (value) {
            if (value == null) {
              currentValue = null;
              widget.creationMap['unitName'] = null;
              controller.text = "";
              return;
            }
            currentValue = value;
            controller.text = value;
            widget.creationMap['unitName'] = value;
          },
        );
      },
    );
  }
}

class _CategoryFormField extends StatefulWidget {
  const _CategoryFormField({
    required this.initialSelection,
    required this.productCaterogriesEntries,
    required this.creationMap,
  });

  final String? initialSelection;
  final Iterable<DropdownMenuEntry<String>> productCaterogriesEntries;
  final Map creationMap;

  @override
  State<_CategoryFormField> createState() => _CategoryFormFieldState();
}

class _CategoryFormFieldState extends State<_CategoryFormField> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(text: widget.initialSelection);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      label: const Text("Categoria"),
      controller: controller,
      initialSelection: widget.initialSelection,
      dropdownMenuEntries: widget.productCaterogriesEntries.toList(),
      onSelected: (value) {
        if (value == null) {
          widget.creationMap['categoryName'] = null;
          controller.text = "";
          return;
        }
        widget.creationMap['categoryName'] = value;
      },
    );
  }
}

class WordChipTextController extends TextEditingController {
  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final List<TextSpan> children = [];
    final regex = RegExp(r"(\S+\s)");

    final chipStyle = TextStyle(
      backgroundColor: Colors.green.withValues(alpha: 0.4),
      color: Colors.green.shade900,
      fontWeight: FontWeight.bold,
    );

    text.splitMapJoin(
      regex,
      onMatch: (Match match) {
        final wordWithSpace = match.group(0)!;
        final word = wordWithSpace.trim();

        children.add(
          TextSpan(text: word, style: chipStyle),
        );

        children.add(
          TextSpan(text: ' ', style: style),
        );

        return '';
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return '';
      },
    );

    return TextSpan(style: style, children: children);
  }
}
