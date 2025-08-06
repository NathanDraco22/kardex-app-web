part of '../product_list_screen.dart';

class ProductListScreenWeb extends StatelessWidget {
  const ProductListScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WebScaffold();
  }
}

class _WebScaffold extends StatelessWidget {
  const _WebScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _WebBody(),
    );
  }
}

class _WebBody extends StatelessWidget {
  const _WebBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("ProductListScreenWeb"),
    );
  }
}
