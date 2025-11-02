import 'package:flutter/material.dart';
import 'package:kardex_app_front/src/modules/commercial/client_devolution/web/no_paid_client_screen_web.dart';

class ClientDevolutionScreen extends StatelessWidget {
  const ClientDevolutionScreen({super.key});

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
    return const NoPaidClientScreenWeb();
  }
}
