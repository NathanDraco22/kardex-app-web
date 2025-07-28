import 'package:flutter/material.dart';
import 'package:kardex_app_front/config/app_router.dart';
import 'package:kardex_app_front/config/app_theme.dart';
import 'package:kardex_app_front/provider_container.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderContainer(
      child: MaterialApp.router(
        title: 'Kardex App',
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        theme: AppTheme().lightTheme,
      ),
    );
  }
}
