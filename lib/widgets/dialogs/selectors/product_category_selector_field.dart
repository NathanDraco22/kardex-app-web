import 'package:kardex_app_front/widgets/dialogs/selectors/product_category_selection_dialog.dart';
import 'package:kardex_app_front/widgets/title_texfield.dart';
import 'package:material_ui/material_ui.dart';

class ProductCategorySelectorField extends StatefulWidget {
  const ProductCategorySelectorField({
    super.key,
    this.initialCategoryName,
    required this.onChanged,
    this.title = "Categoría",
  });

  final String? initialCategoryName;
  final ValueChanged<String?> onChanged;
  final String title;

  @override
  State<ProductCategorySelectorField> createState() => _ProductCategorySelectorFieldState();
}

class _ProductCategorySelectorFieldState extends State<ProductCategorySelectorField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCategoryName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openSelector() async {
    final currentName = _controller.text.trim();
    final selection = await showProductCategorySelectionDialog(
      context,
      selectedCategoryName: currentName.isEmpty ? null : currentName,
    );

    if (!mounted || selection == null) return;

    final categoryName = selection.category?.name;
    setState(() {
      _controller.text = categoryName ?? '';
    });
    widget.onChanged(categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return TitleTextField(
      title: widget.title,
      controller: _controller,
      readOnly: true,
      onTap: _openSelector,
      decoration: const InputDecoration(
        hintText: "Sin categoría",
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
    );
  }
}
