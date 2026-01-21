import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/models/expiration_log/expiration_log.dart';

import 'package:kardex_app_front/src/domain/models/product/product_model.dart';
import 'package:kardex_app_front/src/tools/branches_tool.dart';
import 'package:kardex_app_front/src/tools/datetime_tool.dart';
import 'package:kardex_app_front/src/tools/extensiones.dart';
import 'package:kardex_app_front/src/tools/input_formatter/input_formatter.dart';

import 'package:kardex_app_front/src/tools/loading_dialog.dart';
import 'package:kardex_app_front/widgets/widgets.dart';

import '../cubit/read_expiration_log_cubit.dart';
import '../cubit/write_expiration_log_cubit.dart';

Future<void> showExpirationLogCreationScreen(BuildContext context) async {
  final readCubit = context.read<ReadExpirationLogCubit>();
  final writeCubit = context.read<WriteExpirationLogCubit>();

  await showDialog(
    context: context,
    builder: (context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: readCubit),
          BlocProvider.value(value: writeCubit),
        ],
        child: const ExpirationLogCreationScreen(),
      );
    },
  );
}

class ExpirationLogCreationScreen extends StatefulWidget {
  const ExpirationLogCreationScreen({super.key});

  @override
  State<ExpirationLogCreationScreen> createState() => _ExpirationLogCreationScreenState();
}

class _ExpirationLogCreationScreenState extends State<ExpirationLogCreationScreen> {
  final _formKey = GlobalKey<FormState>();

  ProductInDb? _selectedProduct;
  String? _lotNumber;
  String? _expirationDate;
  DateTime? _expirationDateParsed;

  @override
  Widget build(BuildContext context) {
    return BlocListener<WriteExpirationLogCubit, WriteExpirationLogState>(
      listener: (context, state) async {
        if (state is WriteExpirationLogInProgress) {
          LoadingDialogManager.showLoadingDialog(context);
        }

        if (state is WriteExpirationLogError) {
          LoadingDialogManager.closeLoadingDialog(context);
          if (!context.mounted) return;
          DialogManager.showErrorDialog(context, state.error);
        }

        if (state is WriteExpirationLogSuccess) {
          LoadingDialogManager.closeLoadingDialog(context);
          context.read<ReadExpirationLogCubit>().putLogFirst(state.log);
          await DialogManager.showInfoDialog(context, 'Guardado exitosamente');
          if (!context.mounted) return;
          Navigator.pop(context);
        }
      },
      child: AlertDialog(
        title: const Text("Nueva Bitácora de Vencimiento"),

        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Guardar'),
            onPressed: () async {
              final isValidate = _formKey.currentState?.validate() ?? false;
              if (!isValidate) return;
              if (_expirationDateParsed == null) {
                await DialogManager.showInfoDialog(context, 'Debe seleccionar una fecha de vencimiento');
                return;
              }
              if (_selectedProduct == null) {
                await DialogManager.showInfoDialog(context, 'Debe seleccionar un producto');
                return;
              }

              final newExpirationlog = CreateExpirationLog(
                product: ProductInfo(
                  id: _selectedProduct!.id,
                  name: _selectedProduct!.name,
                  brandName: _selectedProduct!.brandName,
                  unitName: _selectedProduct!.unitName,
                  categoryName: _selectedProduct!.categoryName,
                ),
                branchId: BranchesTool.getCurrentBranchId(),
                expirationDate: _expirationDateParsed!,
              );

              context.read<WriteExpirationLogCubit>().createNewExpirationLog(newExpirationlog);
            },
          ),
        ],
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      final isMobile = context.isMobile();

                      if (isMobile) {
                        _selectedProduct = await showProductSearchDelegate(context);
                      } else {
                        _selectedProduct = await showSearchProductDialog(context);
                      }

                      setState(() {});
                    },
                    label: const Text("Seleccionar Producto"),
                    icon: const Icon(Icons.search),
                  ),

                  ListTile(
                    title: Text(
                      _selectedProduct?.name ?? 'Producto no seleccionado',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Row(
                      spacing: 8,
                      children: [
                        Text(
                          _selectedProduct?.brandName ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _selectedProduct?.unitName ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    spacing: 16,
                    children: [
                      Flexible(
                        child: TitleTextField(
                          title: "Número de Lote (Opcional)",
                          initialValue: _lotNumber,
                          textInputAction: TextInputAction.next,
                          onChanged: (value) {
                            _lotNumber = value;
                          },
                        ),
                      ),

                      Flexible(
                        child: TitleTextField(
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            MonthYearInputFormatter(),
                          ],
                          keyboardType: TextInputType.number,
                          title: "Fecha de Vencimiento (MES/AÑO)",
                          initialValue: _expirationDate,
                          onChanged: (value) {
                            _expirationDate = value;
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              _expirationDateParsed = null;
                              return "Campo requerido";
                            }

                            if (value.length < 5) return "Formato de fecha inválido";
                            try {
                              _expirationDateParsed = DateTimeTool.fromMMYY(value);
                            } on Exception catch (_) {
                              return "Formato de fecha inválido";
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
