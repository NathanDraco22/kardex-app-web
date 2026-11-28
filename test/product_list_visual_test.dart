import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/cubit/read_product_cubit.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/view/product_list_screen.dart';
import 'package:kardex_app_front/src/modules/product_catalog/product_list/view/widgets/products_table.dart';
import 'package:kardex_app_front/widgets/super_widgets/image_viewer_widget.dart';
import 'package:kardex_business/kardex_business.dart';
import 'package:material_ui/material_ui.dart';

class _FakeProductsRepository implements ProductsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeUnitsRepository implements UnitsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestReadProductCubit extends ReadProductCubit {
  _TestReadProductCubit(List<ProductInDb> initialProducts)
    : super(
        productsRepository: _FakeProductsRepository(),
        unitsRepository: _FakeUnitsRepository(),
      ) {
    isLastPage = true;
    // ignore: invalid_use_of_visible_for_testing_member
    emit(ReadProductSuccess(initialProducts));
  }
}

ProductInDb _buildProduct({
  required String id,
  required String name,
  String image = '',
  String code = '123456',
  String altCode = '',
  String brandName = 'MarcaTest',
  String? categoryName = 'Bebidas',
  ProductType productType = ProductType.item,
  bool isActive = true,
}) {
  return ProductInDb(
    id: id,
    name: name,
    code: code,
    altCode: altCode,
    brandName: brandName,
    unitName: 'Unidad',
    categoryName: categoryName,
    tags: const [],
    hasIva: false,
    isActive: isActive,
    image: image,
    productType: productType,
    createdAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
  );
}

void main() {
  final sampleProducts = [
    _buildProduct(
      id: 'p1',
      name: 'Café Molido 500g',
      image: 'https://example.com/cafe.jpg',
      code: '7501001',
      altCode: 'CF-500',
      brandName: 'Café Oro',
      categoryName: 'Abarrotes',
    ),
    _buildProduct(
      id: 'p2',
      name: 'Servicio de Instalación',
      image: '',
      code: '',
      brandName: '',
      categoryName: null,
      productType: ProductType.service,
      isActive: false,
    ),
  ];

  testWidgets('ProductsTable (Web/Desktop) muestra imagen en cada fila y pie de tabla', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = _TestReadProductCubit(sampleProducts);
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BlocProvider<ReadProductCubit>.value(
            value: cubit,
            child: const ProductsTable(),
          ),
        ),
      ),
    );

    final imageWidgets = tester.widgetList<ImageViewerWidget>(find.byType(ImageViewerWidget)).toList();
    expect(imageWidgets, hasLength(2));
    expect(imageWidgets[0].imageUrls, ['https://example.com/cafe.jpg']);
    expect(imageWidgets[1].imageUrls, isEmpty);

    expect(find.text('Café Molido 500g'), findsOneWidget);
    expect(find.text('Servicio de Instalación'), findsOneWidget);
    expect(find.text('Productos mostrados: 2'), findsOneWidget);
    expect(find.text('--'), findsAtLeastNWidgets(2));
  });

  testWidgets('ProductListScreenMobile muestra imagen en filas, chips de filtro y FAB', (tester) async {
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = _TestReadProductCubit(sampleProducts);
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ReadProductCubit>.value(
          value: cubit,
          child: const ProductListScreenMobile(),
        ),
      ),
    );

    final imageWidgets = tester.widgetList<ImageViewerWidget>(find.byType(ImageViewerWidget)).toList();
    expect(imageWidgets, hasLength(2));
    expect(imageWidgets[0].imageUrls, ['https://example.com/cafe.jpg']);
    expect(imageWidgets[1].imageUrls, isEmpty);

    expect(find.text('Café Molido 500g'), findsOneWidget);
    expect(find.text('Nuevo Producto'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('Artículos'), findsOneWidget);
    expect(find.text('Servicios'), findsOneWidget);
  });
}
