import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:kardex_app_front/config/app_router.dart';
import 'package:kardex_app_front/config/app_theme.dart';
import 'package:kardex_app_front/provider_container.dart';

import 'config/scroll_behavior.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderContainer(
      child: MaterialApp.router(
        title: 'Kardex App',
        routerConfig: AppRouter.router,
        builder: (context, child) {
          final mediaQueryData = MediaQuery.of(context);
          final systemTextScalerFactor = mediaQueryData.textScaler;
          return MediaQuery(
            data: mediaQueryData.copyWith(
              textScaler: systemTextScalerFactor.clamp(
                minScaleFactor: 0.8,
                maxScaleFactor: 1.2,
              ),
            ),
            child: child!,
          );
        },
        debugShowCheckedModeBanner: false,
        scrollBehavior: AlwaysStretchScrollBehavior(),
        theme: AppTheme().lightTheme,
      ),
    );
  }
}
