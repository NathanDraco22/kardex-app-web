part of '../product_category_screen.dart';

class ProductCategoryMobile extends StatelessWidget {
  const ProductCategoryMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MobileScaffold();
  }
}

class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: _MobileBody(),
    );
  }
}

class _MobileBody extends StatelessWidget {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text("ProductCategoryMobile"),
    );
  }
}
