import 'package:flutter/material.dart';
import 'package:kardex_app_front/widgets/menu_app_bar.dart';

import 'web/create_transfer_screen_web.dart';

class CreateTransferScreen extends StatelessWidget {
  const CreateTransferScreen({super.key});

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
      appBar: MenuAppBar(
        title: "Create Transferencia",
      ),
      body: _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return const CreateTransferScreenWeb();
  }
}
