import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/config/get_it_config.dart';
import 'package:kardex_app_front/cubits/auth/auth_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/cubit/read_terminal_product_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/cubit/write_terminal_invoice_cubit.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/view_controller.dart';
import 'package:kardex_app_front/src/modules/commercial/sale_terminal/web/sale_terminal_screen_web.dart';
import 'package:kardex_app_front/widgets/widgets.dart';
import 'package:kardex_business/kardex_business.dart';

class SaleTerminalScreen extends StatefulWidget {
  const SaleTerminalScreen({super.key});

  @override
  State<SaleTerminalScreen> createState() => _SaleTerminalScreenState();
}

class _SaleTerminalScreenState extends State<SaleTerminalScreen> {
  late final SaleTerminalViewController viewController;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    viewController = SaleTerminalViewController();
    viewController.requestSearchFocus();
  }

  @override
  void dispose() {
    viewController.dispose();
    super.dispose();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final authState = getIt<AuthCubit>().state;
    if (authState is! Authenticated) {
      return const Scaffold(
        body: Center(
          child: Text("Error de Autenticación"),
        ),
      );
    }

    final invoicesRepo = context.read<InvoicesRepository>();
    final productsRepo = context.read<ProductsRepository>();

    return ShortcutContainer(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ReadTerminalProductCubit(
              productsRepository: productsRepo,
              branchId: authState.branch.id,
            )..loadProducts(),
          ),
          BlocProvider(
            create: (context) => WriteTerminalInvoiceCubit(
              invoicesRepository: invoicesRepo,
              viewController: viewController,
            ),
          ),
        ],
        child: const _RootScaffold(),
      ),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final viewController = context.read<WriteTerminalInvoiceCubit>().viewController;

    return SaleTerminalScreenWeb(viewController: viewController);
  }
}
