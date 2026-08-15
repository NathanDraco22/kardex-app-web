import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kardex_app_front/config/app_router.dart';
import 'package:kardex_app_front/config/app_theme.dart';
import 'package:kardex_app_front/cubits/app_mode/app_mode_cubit.dart';
import 'package:kardex_app_front/provider_container.dart';

import 'config/scroll_behavior.dart';
import 'material_app_builder.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);

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
    context.watch<AppModeCubit>();
    return MaterialApp.router(
      title: 'Neptuno App',
      routerConfig: AppRouter.router,
      builder: materialAppBuilder,
      debugShowCheckedModeBanner: false,
      scrollBehavior: AlwaysStretchScrollBehavior(),
      theme: AppTheme().lightTheme,
    );
  }
}
