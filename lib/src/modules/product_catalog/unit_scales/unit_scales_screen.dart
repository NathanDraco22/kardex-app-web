import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/src/modules/product_catalog/unit_scales/cubit/read_unit_scales_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/unit_scales/cubit/write_unit_scale_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/unit_scales/panels/unit_scales_panel.dart';
import 'package:kardex_business/kardex_business.dart';

class UnitScalesScreen extends StatelessWidget {
  const UnitScalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.read<UnitScalesRepository>();
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadUnitScalesCubit(repo)..loadAllUnitScales(),
        ),
        BlocProvider(
          create: (context) => WriteUnitScaleCubit(repo),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            "Escalas de Unidades de Medida",
            style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.2),
          ),
        ),
        body: const UnitScalesPanel(),
      ),
    );
  }
}
