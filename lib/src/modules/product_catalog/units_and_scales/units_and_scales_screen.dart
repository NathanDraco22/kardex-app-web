import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kardex_app_front/constants/feature_flags.dart';
import 'package:kardex_app_front/src/modules/product_catalog/unit_scales/cubit/read_unit_scales_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/unit_scales/cubit/write_unit_scale_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/unit_scales/panels/unit_scales_panel.dart';
import 'package:kardex_app_front/src/modules/product_catalog/units/cubit/read_unit_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/units/cubit/write_unit_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/units/panels/units_panel.dart';
import 'package:kardex_app_front/widgets/design_system/design_system.dart';
import 'package:kardex_business/kardex_business.dart';

/// Pantalla combinada para gestionar unidades de medida y escalas de conversión.
///
/// [initialTab] permite abrir directamente la pestaña de unidades (0) o de
/// escalas (1), lo que facilita la compatibilidad con las rutas heredadas.
class UnitsAndScalesScreen extends StatelessWidget {
  final int initialTab;

  const UnitsAndScalesScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  Widget build(BuildContext context) {
    const showUnitScales = FeatureFlags.showUnitScales;
    final resolvedInitialTab = showUnitScales && initialTab == 1 ? 1 : 0;
    final unitsRepository = context.read<UnitsRepository>();
    final UnitScalesRepository? unitScalesRepository = showUnitScales ? context.read<UnitScalesRepository>() : null;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ReadUnitCubit(unitsRepository)..loadAllUnits(),
        ),
        BlocProvider(
          create: (context) => WriteUnitCubit(unitsRepository),
        ),
        if (showUnitScales) ...[
          BlocProvider(
            create: (context) => ReadUnitScalesCubit(unitScalesRepository!)..loadAllUnitScales(),
          ),
          BlocProvider(
            create: (context) => WriteUnitScaleCubit(unitScalesRepository!),
          ),
        ],
      ],
      child: DefaultTabController(
        key: ValueKey(resolvedInitialTab),
        length: showUnitScales ? 2 : 1,
        initialIndex: resolvedInitialTab,
        child: Scaffold(
          backgroundColor: AppThemeTokens.surfaceLight,
          appBar: AppBar(
            title: const Text(
              showUnitScales ? "Unidades y Escalas de Medida" : "Unidades de Medida",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: -0.2),
            ),
            bottom: showUnitScales
                ? const TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.amber,
                    indicatorWeight: 3,
                    tabs: [
                      Tab(
                        icon: Icon(Icons.tag_rounded),
                        text: "Unidades",
                      ),
                      Tab(
                        icon: Icon(Icons.straighten_rounded),
                        text: "Escalas",
                      ),
                    ],
                  )
                : null,
          ),
          body: const SafeArea(
            top: false,
            child: TabBarView(
              children: [
                UnitsPanel(),
                if (showUnitScales) UnitScalesPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
