import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/client_catalog/cllient_map/web/client_map_screen_web.dart';

class ClientMapScreen extends StatelessWidget {
  const ClientMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _RootScaffold();
  }
}

class _RootScaffold extends StatelessWidget {
  const _RootScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const ClientMapScreenWeb();
  }
}
