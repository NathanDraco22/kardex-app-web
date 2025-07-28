import 'package:go_router/go_router.dart';
import 'package:kardex_app_front/src/modules/client_catalog/view/client_catalog_screen.dart';
import 'package:kardex_app_front/src/modules/home/view/home_screen.dart';
import 'package:kardex_app_front/src/modules/product_catalog/view/product_catalog_screen.dart';

class AppRouter {
  static GoRouter router = GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      GoRoute(
        path: '/product-catalog',
        name: 'product-catalog',
        builder: (context, state) => const ProductCatalogScreen(),
      ),

      GoRoute(
        path: '/client-catalog',
        name: 'client-catalog',
        builder: (context, state) => const ClientCatalogScreen(),
      ),
    ],
  );
}
