import 'package:flutter/material.dart';

class ProductPriceSettingMobile extends StatelessWidget {
  const ProductPriceSettingMobile({super.key});

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
    return const Center(
      child: Text("ProductPriceSettingMobile"),
    );
  }
}
