import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kardex_app_front/config/app_router.dart';
import 'package:kardex_app_front/config/app_theme.dart';
import 'package:kardex_app_front/cubits/app_mode/app_mode_cubit.dart';
import 'package:kardex_app_front/provider_container.dart';

import 'config/scroll_behavior.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await initializeDateFormatting('es');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderContainer(
      child: AppRoot(),
    );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final appModeCubit = context.watch<AppModeCubit>();
    return MaterialApp.router(
      title: 'Neptuno App',
      routerConfig: AppRouter.router,
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        final systemTextScalerFactor = mediaQueryData.textScaler;

        Widget childWidget = child!;

        if (appModeCubit.state is PracticeModeState) {
          childWidget = Stack(
            children: [
              child,
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(90),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Modo Practica",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return MediaQuery(
          data: mediaQueryData.copyWith(
            textScaler: systemTextScalerFactor.clamp(
              minScaleFactor: 0.8,
              maxScaleFactor: 1.2,
            ),
          ),
          child: childWidget,
        );
      },
      debugShowCheckedModeBanner: false,
      scrollBehavior: AlwaysStretchScrollBehavior(),
      theme: AppTheme().lightTheme,
    );
  }
}
