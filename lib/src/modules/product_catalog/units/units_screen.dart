import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/product_catalog/units/cubit/read_unit_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/units/cubit/write_unit_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/units/panels/units_panel.dart';
import 'package:kardex_business/kardex_business.dart';

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
      child: Scaffold(
        appBar: AppBar(title: const Text("Unidades de Medida")),
        body: const UnitsPanel(),
      ),
    );
  }
}
