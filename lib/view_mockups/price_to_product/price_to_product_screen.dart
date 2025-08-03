import 'package:flutter/material.dart';

part 'mobile/price_to_product_mobile.dart';
part 'web/price_to_product_web.dart';

class PriceToProductScreen extends StatelessWidget {
  const PriceToProductScreen({super.key});

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
      child: Text("PriceToProductScreen"),
    );
  }
}
