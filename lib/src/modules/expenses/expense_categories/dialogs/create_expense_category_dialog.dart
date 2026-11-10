import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/cubits/expense_category_cubit/write_expense_categories_cubit.dart';
import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/buttons/primary_menu_button.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_app_front/widgets/dialogs/dialog_manager.dart';
import 'package:kardex_business/kardex_business.dart';

Future<ExpenseCategoryInDb?> showCreateExpenseCategoryDialog(
  BuildContext context, {
  ExpenseCategoryInDb? category,
}) async {
  final cubit = context.read<WriteExpenseCategoryCubit>();
  final isCompact = MediaQuery.sizeOf(context).width < 700;

  final dialog = BlocProvider.value(
    value: cubit,
    child: CreateExpenseCategoryDialog(
      category: category,
      isFullScreen: isCompact,
    ),
  );

  if (isCompact) {
    return showDialog<ExpenseCategoryInDb?>(
      context: context,
      useSafeArea: false,
      barrierDismissible: false,
      builder: (_) => Dialog.fullscreen(child: dialog),
    );
  }

  return showDialog<ExpenseCategoryInDb?>(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: dialog,
      ),
    ),
  );
}

class CreateExpenseCategoryDialog extends StatefulWidget {
  const CreateExpenseCategoryDialog({
    super.key,
    this.category,
    this.isFullScreen = false,
  });

  final ExpenseCategoryInDb? category;
  final bool isFullScreen;

  @override
  State<CreateExpenseCategoryDialog> createState() => _CreateExpenseCategoryDialogState();
}

class _CreateExpenseCategoryDialogState extends State<CreateExpenseCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  bool get _isEditing => widget.category != null;

  String get _title => _isEditing ? 'Editar Categoría' : 'Nueva Categoría';

  String get _submitLabel => _isEditing ? 'Actualizar' : 'Crear';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController = TextEditingController(text: widget.category?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final currentCategory = widget.category;

    if (currentCategory == null) {
      final confirmed = await DialogManager.slideToConfirmActionDialog(
        context,
        '¿Desea crear la categoría $name?',
      );
      if (!confirmed || !mounted) return;

      context.read<WriteExpenseCategoryCubit>().create(
        CreateExpenseCategory(name: name, description: description),
      );
      return;
    }

    final confirmed = await DialogManager.slideToConfirmActionDialog(
      context,
      '¿Desea actualizar la categoría $name?',
    );
    if (!confirmed || !mounted) return;

    context.read<WriteExpenseCategoryCubit>().update(
      currentCategory.id,
      UpdateExpenseCategory(name: name, description: description),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteExpenseCategoryCubit, WriteExpenseCategoryState>(
      listener: (context, state) {
        if (state is WritingExpenseCategory) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteExpenseCategorySuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.pop(state.item);
        }

        if (state is WriteExpenseCategoryError) {
          LoadingDialogManager.closeLoadingDialog(context);
          DialogManager.showErrorDialog(context, state.message);
        }
      },
      child: Form(
        key: _formKey,
        child: widget.isFullScreen ? _buildFullScreen(context) : _buildDesktopDialog(context),
      ),
    );
  }

  Widget _buildDesktopDialog(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: AppThemeTokens.borderRadiusXl,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppDialogHeader(
            title: _title,
            subtitle: _isEditing
                ? 'Actualiza el nombre o la descripción de la categoría.'
                : 'Agrupa los gastos operativos con una etiqueta reutilizable.',
            icon: Icons.category_rounded,
            accentColor: AppThemeTokens.indigo,
            onClose: () => Navigator.of(context).pop(),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildFields(),
            ),
          ),
          _buildDesktopFooter(context),
        ],
      ),
    );
  }

  Widget _buildFullScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          tooltip: 'Cerrar',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppThemeTokens.borderLight),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppThemeTokens.borderRadiusLg,
              border: Border.all(color: AppThemeTokens.borderLight),
              boxShadow: AppThemeTokens.subtleCardShadow(),
            ),
            child: _buildFields(),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppThemeTokens.borderLight)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppThemeTokens.borderRadiusMd,
                    ),
                  ),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PrimaryMenuButton(
                  onPressed: _submit,
                  backgroundColor: AppThemeTokens.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  label: Text(
                    _submitLabel,
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          maxLength: 60,
          inputFormatters: [LengthLimitingTextInputFormatter(60)],
          decoration: _fieldDecoration(
            label: 'Nombre *',
            hint: 'Ej. Servicios básicos',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Campo requerido';
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          textCapitalization: TextCapitalization.sentences,
          minLines: 3,
          maxLines: 4,
          maxLength: 200,
          inputFormatters: [LengthLimitingTextInputFormatter(200)],
          decoration: _fieldDecoration(
            label: 'Descripción',
            hint: 'Describe el tipo de gastos que agrupa esta categoría...',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    bool alignLabelWithHint = false,
  }) {
    final border = OutlineInputBorder(
      borderRadius: AppThemeTokens.borderRadiusMd,
      borderSide: const BorderSide(color: AppThemeTokens.borderLight),
    );

    return InputDecoration(
      labelText: label,
      hintText: hint,
      alignLabelWithHint: alignLabelWithHint,
      counterStyle: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: AppThemeTokens.borderRadiusMd,
        borderSide: const BorderSide(color: AppThemeTokens.indigo, width: 1.5),
      ),
    );
  }

  Widget _buildDesktopFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppThemeTokens.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF475569),
              minimumSize: const Size(44, 44),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          PrimaryMenuButton(
            onPressed: _submit,
            backgroundColor: AppThemeTokens.indigo,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            label: Text(
              _submitLabel,
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
