import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/domain/repositories/repositories.dart';
import 'package:kardex_app_front/src/modules/product_catalog/units/cubit/read_unit_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/units/cubit/write_unit_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/units/dialog/create_unit_dialog.dart';

part 'web/units_screen_web.dart';

class UnitsScreen extends StatelessWidget {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unitRepo = context.read<UnitsRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => ReadUnitCubit(unitRepo)..loadAllUnits()),
        BlocProvider(create: (context) => WriteUnitCubit(unitRepo)),
      ],
      child: const _RootScaffold(),
    );
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return const UnitsScreenWeb();
  }
}
